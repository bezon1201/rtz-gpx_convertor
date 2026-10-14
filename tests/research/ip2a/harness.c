/* Research-only libxml2 security harness. Never use for product conversion. */
#define _DARWIN_C_SOURCE 1
#include <libxml/parser.h>
#include <libxml/xmlerror.h>
#include <libxml/xmlIO.h>
#include <libxml/xmlschemas.h>
#include <CommonCrypto/CommonDigest.h>
#include <stdatomic.h>
#include <pthread.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define BYTE_CAP (16u * 1024u * 1024u)
#define DEPTH_CAP 64u
#define NODE_CAP 250000u
#define VALUE_CAP 4096u
#define TEXT_CAP (8u * 1024u * 1024u)
#define OPTIONS (XML_PARSE_NONET | XML_PARSE_NO_XXE | XML_PARSE_NO_SYS_CATALOG | XML_PARSE_BIG_LINES)

typedef struct {
    const unsigned char *memory;
    size_t length, offset, bytes;
    int fd, close_count, loader_count, doctype, stopped, depth, max_depth;
    int read_calls, reads_after_cancel, cancel_observed, close_delay_us;
    unsigned long nodes, text_bytes, attr_bytes, current_text;
    const char *reason;
    atomic_int *cancel;
    atomic_int *cleanup_signal;
    int slow_us;
    xmlParserCtxt *ctxt;
} State;

static double now_ms(void) {
    struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t);
    return (double)t.tv_sec * 1000.0 + (double)t.tv_nsec / 1000000.0;
}

static void sha_hex(const void *data, size_t n, char out[65]) {
    unsigned char d[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data, (CC_LONG)n, d);
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) sprintf(out + 2*i, "%02x", d[i]);
    out[64] = 0;
}

static void stop(State *s, const char *reason) {
    if (!s->reason) s->reason = reason;
    s->stopped = 1;
    if (s->ctxt) xmlStopParser(s->ctxt);
}

static int read_cb(void *ctx, char *buf, int len) {
    State *s = ctx;
    s->read_calls++;
    if (s->cancel_observed) s->reads_after_cancel++;
    if (s->cancel && atomic_load_explicit(s->cancel, memory_order_acquire)) {
        s->cancel_observed = 1;
        s->reason = "CANCELLED_READ"; return -1;
    }
    if (s->slow_us) usleep((useconds_t)s->slow_us);
    if (s->cancel && atomic_load_explicit(s->cancel, memory_order_acquire)) {
        s->cancel_observed = 1;
        s->reason = "CANCELLED_READ"; return -1;
    }
    if (s->bytes > BYTE_CAP) { s->reason = "BYTE_LIMIT"; return -1; }
    size_t remain = 0;
    if (s->memory) remain = s->length - s->offset;
    if (s->fd >= 0) {
        size_t allowance = BYTE_CAP + 1u - s->bytes;
        size_t ask = (size_t)len;
        if (ask > allowance) ask = allowance;
        ssize_t n = read(s->fd, buf, ask);
        if (n < 0) { s->reason = "IO_ERROR"; return -1; }
        if (n == 0) return 0;
        s->bytes += (size_t)n;
        if (s->bytes > BYTE_CAP) { s->reason = "BYTE_LIMIT"; return -1; }
        return (int)n;
    }
    if (remain == 0) return 0;
    size_t n = remain < (size_t)len ? remain : (size_t)len;
    size_t allowance = BYTE_CAP + 1u - s->bytes;
    if (n > allowance) n = allowance;
    memcpy(buf, s->memory + s->offset, n);
    s->offset += n; s->bytes += n;
    if (s->bytes > BYTE_CAP) { s->reason = "BYTE_LIMIT"; return -1; }
    return (int)n;
}

static int close_cb(void *ctx) {
    State *s = ctx; s->close_count++;
    if (s->cleanup_signal) atomic_store_explicit(s->cleanup_signal, 1, memory_order_release);
    if (s->close_delay_us) usleep((useconds_t)s->close_delay_us);
    if (s->fd >= 0) { close(s->fd); s->fd = -1; }
    return 0;
}

static xmlParserErrors deny_loader(void *ctx, const char *url, const char *id,
                                   xmlResourceType type, xmlParserInputFlags flags,
                                   xmlParserInput **out) {
    State *s = ctx; (void)url; (void)id; (void)type; (void)flags;
    s->loader_count++;
    if (out) *out = NULL;
    return XML_IO_LOAD_ERROR;
}

static void on_doctype(void *ctx, const xmlChar *name, const xmlChar *external,
                       const xmlChar *system) {
    State *s = ctx; (void)name; (void)external; (void)system;
    s->doctype++;
    stop(s, "DOCTYPE_FORBIDDEN");
}

static void on_start(void *ctx, const xmlChar *local, const xmlChar *prefix,
                     const xmlChar *uri, int ns_count, const xmlChar **namespaces,
                     int attr_count, int defaulted, const xmlChar **attrs) {
    State *s = ctx; (void)local; (void)prefix; (void)uri; (void)ns_count;
    (void)namespaces; (void)defaulted;
    s->nodes++; s->depth++; s->current_text = 0;
    if (s->depth > s->max_depth) s->max_depth = s->depth;
    if ((unsigned)s->depth > DEPTH_CAP) { stop(s, "DEPTH_LIMIT"); return; }
    if (s->nodes > NODE_CAP) { stop(s, "ELEMENT_LIMIT"); return; }
    if (attr_count > 64) { stop(s, "ATTRIBUTE_COUNT_LIMIT"); return; }
    for (int i = 0; i < attr_count; i++) {
        const xmlChar *begin = attrs[i*5 + 3], *end = attrs[i*5 + 4];
        size_t n = (begin && end && end >= begin) ? (size_t)(end - begin) : 0;
        s->attr_bytes += n;
        if (n > VALUE_CAP) { stop(s, "ATTRIBUTE_VALUE_LIMIT"); return; }
    }
}

static void on_end(void *ctx, const xmlChar *local, const xmlChar *prefix, const xmlChar *uri) {
    State *s = ctx; (void)local; (void)prefix; (void)uri;
    s->current_text = 0;
    if (s->depth > 0) s->depth--;
}

static void on_chars(void *ctx, const xmlChar *ch, int len) {
    State *s = ctx; (void)ch;
    if (len <= 0) return;
    s->text_bytes += (unsigned long)len;
    s->current_text += (unsigned long)len;
    if (s->current_text > VALUE_CAP) { stop(s, "TEXT_VALUE_LIMIT"); return; }
    if (s->text_bytes > TEXT_CAP) stop(s, "TEXT_TOTAL_LIMIT");
}

static void on_comment(void *ctx, const xmlChar *value) {
    State *s = ctx; (void)value; s->current_text = 0;
}

static void on_error(void *ctx, const xmlError *error) {
    State *s = ctx;
    if (!s->reason && error && error->level >= XML_ERR_ERROR) s->reason = "MALFORMED_XML";
}

static void quiet_schema_error(void *ctx, const char *message, ...) {
    State *s = ctx; (void)message;
    if (!s->reason) s->reason = "SCHEMA_RESOURCE_DENIED";
}

static void quiet_generic_error(void *ctx, const char *message, ...) {
    (void)ctx; (void)message;
}

static int parse_state(State *s, unsigned long *elapsed_us) {
    xmlSAXHandler sax; memset(&sax, 0, sizeof(sax)); sax.initialized = XML_SAX2_MAGIC;
    sax.internalSubset = on_doctype; sax.startElementNs = on_start;
    sax.endElementNs = on_end; sax.characters = on_chars; sax.comment = on_comment;
    double start = now_ms();
    xmlParserCtxt *ctxt = xmlNewSAXParserCtxt(&sax, s);
    if (!ctxt) return 0;
    s->ctxt = ctxt;
    xmlCtxtSetErrorHandler(ctxt, on_error, s);
    xmlCtxtSetResourceLoader(ctxt, deny_loader, s);
    if (xmlCtxtSetOptions(ctxt, OPTIONS) != 0) s->reason = "OPTIONS_UNAVAILABLE";
    if (!s->reason) (void)xmlCtxtReadIO(ctxt, read_cb, close_cb, s, NULL, NULL, OPTIONS);
    if (s->close_count == 0) close_cb(s);
    if (s->cancel && atomic_load_explicit(s->cancel, memory_order_acquire) && !s->reason)
        s->reason = "CANCELLED_CLEANUP";
    int status = xmlCtxtGetStatus(ctxt);
    int accepted = !s->reason && !s->stopped &&
                   (status & (XML_STATUS_NOT_WELL_FORMED | XML_STATUS_NOT_NS_WELL_FORMED |
                              XML_STATUS_DTD_VALIDATION_FAILED | XML_STATUS_CATASTROPHIC_ERROR)) == 0 &&
                   s->loader_count == 0;
    if (!accepted && !s->reason) s->reason = s->loader_count ? "RESOURCE_DENIED" : "MALFORMED_XML";
    xmlFreeParserCtxt(ctxt);
    if (elapsed_us) *elapsed_us = (unsigned long)((now_ms()-start)*1000.0);
    return accepted;
}

static int parse_bytes(const unsigned char *data, size_t length, State *out, int slow_us,
                       atomic_int *cancel, unsigned long *elapsed_us) {
    State s = {0}; s.fd = -1; s.memory = data; s.length = length; s.slow_us = slow_us; s.cancel = cancel;
    int accepted = parse_state(&s, elapsed_us); if (out) *out = s; return accepted;
}

static int parse_fd_bytes_ex(const unsigned char *data, size_t length, State *out, int slow_us,
                             atomic_int *cancel, atomic_int *cleanup_signal, int close_delay_us,
                             unsigned long *elapsed_us) {
    char path[] = "/tmp/ip2a-r3-input-XXXXXX";
    int fd = mkstemp(path); if (fd < 0) return 0;
    unlink(path);
    size_t offset = 0;
    while (offset < length) {
        ssize_t written = write(fd, data + offset, length - offset);
        if (written <= 0) { close(fd); return 0; }
        offset += (size_t)written;
    }
    if (lseek(fd, 0, SEEK_SET) < 0) { close(fd); return 0; }
    State s = {0}; s.fd = fd; s.slow_us=slow_us; s.cancel=cancel;
    s.cleanup_signal=cleanup_signal; s.close_delay_us=close_delay_us;
    int accepted = parse_state(&s, elapsed_us); if (out) *out = s; return accepted;
}

static int parse_fd_bytes(const unsigned char *data, size_t length, State *out, unsigned long *elapsed_us) {
    return parse_fd_bytes_ex(data,length,out,0,NULL,NULL,0,elapsed_us);
}

static unsigned char *make_xml(const char *kind, size_t n, size_t *out_len) {
    const char *prefix="<r>", *suffix="</r>"; size_t p=3, q=4;
    if (!strcmp(kind,"attr")) { prefix="<r a=\""; p=strlen(prefix); suffix="\"/>"; q=3; }
    if (!strcmp(kind,"text")) { prefix="<r>"; p=3; suffix="</r>"; q=4; }
    if (!strcmp(kind,"nodes")) { prefix="<r>"; p=3; suffix="</r>"; q=4; }
    if (!strcmp(kind,"bytes")) { prefix="<r>"; p=3; suffix="</r>"; q=4; }
    if (!strcmp(kind,"segtext")) { prefix="<r>"; p=3; suffix="</r>"; q=4; }
    if (!strcmp(kind,"attrs")) {
        size_t capacity=32u+n*12u; unsigned char *a=malloc(capacity); if(!a)return NULL;
        size_t k=(size_t)snprintf((char*)a,capacity,"<r");
        for(size_t i=0;i<n;i++) k+=(size_t)snprintf((char*)a+k,capacity-k," a%zu='x'",i);
        k+=(size_t)snprintf((char*)a+k,capacity-k,"/>"); *out_len=k; return a;
    }
    if (!strcmp(kind,"deep")) {
        size_t depth=n; unsigned char *b=malloc(depth*7+1); if(!b)return NULL;
        size_t k=0; for(size_t i=0;i<depth;i++){memcpy(b+k,"<x>",3);k+=3;}
        for(size_t i=0;i<depth;i++){memcpy(b+k,"</x>",4);k+=4;} b[k]=0;*out_len=k;return b;
    }
    size_t middle=n;
    if (!strcmp(kind,"nodes")) middle=n*4;
    if (!strcmp(kind,"bytes")) middle=n-p-q;
    size_t chunks=0;
    if (!strcmp(kind,"segtext")) { chunks=(n+VALUE_CAP-1u)/VALUE_CAP; middle=n+chunks*7u; }
    unsigned char *b=malloc(p+middle+q+1); if(!b)return NULL;
    memcpy(b,prefix,p); size_t k=p;
    if (!strcmp(kind,"nodes")) { for(size_t i=0;i<n;i++){memcpy(b+k,"<x/>",4);k+=4;} }
    else if (!strcmp(kind,"bytes")) {
        size_t remaining=middle;
        while(remaining>=7){
            size_t block=remaining>1007?1007:remaining;
            if(remaining>block && remaining-block<7) block-=7-(remaining-block);
            memcpy(b+k,"<!--",4);k+=4;
            memset(b+k,'a',block-7);k+=block-7;
            memcpy(b+k,"-->",3);k+=3;remaining-=block;
        }
        if(remaining){memset(b+k,' ',remaining);k+=remaining;}
    }
    else if (!strcmp(kind,"segtext")) {
        size_t remaining=n;
        while(remaining){
            memcpy(b+k,"<!---->",7);k+=7;
            size_t part=remaining>VALUE_CAP?VALUE_CAP:remaining;
            memset(b+k,'a',part);k+=part;remaining-=part;
        }
    } else memset(b+k,'a',middle), k+=middle;
    memcpy(b+k,suffix,q);k+=q;b[k]=0;*out_len=k;return b;
}

static int run_one(const char *id, const unsigned char *data, size_t n, int expected) {
    State s; unsigned long us=0; char hash[65]; sha_hex(data,n,hash);
    int actual=parse_bytes(data,n,&s,0,NULL,&us);
    int pass=(actual==expected) && s.loader_count==0 && s.close_count==1;
    printf("{\"case\":\"%s\",\"input_sha256\":\"%s\",\"bytes\":%zu,\"expected\":\"%s\",\"observed\":\"%s\",\"exit_status\":%d,\"libxml2\":\"%s\",\"loader_calls\":%d,\"doctype_callbacks\":%d,\"nodes\":%lu,\"max_depth\":%d,\"text_bytes\":%lu,\"attr_bytes\":%lu,\"close_calls\":%d,\"elapsed_us\":%lu,\"error\":\"%s\"}\n",
      id,hash,n,expected?"accepted":"rejected",actual?"accepted":"rejected",pass?0:1,xmlParserVersion,
      s.loader_count,s.doctype,s.nodes,s.max_depth,s.text_bytes,s.attr_bytes,s.close_count,us,s.reason?s.reason:"NONE");
    return pass?0:1;
}

static int run_fd_one(const char *id, const unsigned char *data, size_t n, int expected, size_t expected_read) {
    State s; unsigned long us=0; char hash[65]; sha_hex(data,n,hash);
    int actual=parse_fd_bytes(data,n,&s,&us);
    int pass=(actual==expected) && s.loader_count==0 && s.close_count==1 && s.bytes==expected_read;
    printf("{\"case\":\"%s\",\"input_sha256\":\"%s\",\"input_bytes\":%zu,\"read_bytes\":%zu,\"expected\":\"%s\",\"observed\":\"%s\",\"exit_status\":%d,\"library\":\"%s\",\"loader_calls\":%d,\"close_calls\":%d,\"elapsed_us\":%lu,\"error\":\"%s\"}\n",
      id,hash,n,s.bytes,expected?"accepted":"rejected",actual?"accepted":"rejected",pass?0:1,xmlParserVersion,s.loader_count,s.close_count,us,s.reason?s.reason:"NONE");
    return pass?0:1;
}

typedef struct { atomic_int *cancel; atomic_int *gate; unsigned int delay_us; } CancelArgs;

static void *cancel_thread(void *arg) {
    CancelArgs *a=arg;
    if(a->gate){while(!atomic_load_explicit(a->gate,memory_order_acquire)) usleep(100);}
    if(a->delay_us) usleep(a->delay_us);
    atomic_store_explicit(a->cancel,1,memory_order_release);
    return NULL;
}

static int run_cancel_read(void) {
    size_t n=0; unsigned char *data=make_xml("bytes",BYTE_CAP,&n);
    if(!data)return 1;
    atomic_int cancel=0; State s; unsigned long us=0; char hash[65]; sha_hex(data,n,hash);
    CancelArgs args={&cancel,NULL,25000}; pthread_t thread;
    if(pthread_create(&thread,NULL,cancel_thread,&args)!=0){free(data);return 1;}
    int accepted=parse_fd_bytes_ex(data,n,&s,2000,&cancel,NULL,0,&us);
    pthread_join(thread,NULL); free(data);
    int pass=!accepted && s.reason && !strcmp(s.reason,"CANCELLED_READ") &&
             s.close_count==1 && s.read_calls>0 && s.reads_after_cancel==0;
    printf("{\"case\":\"async_cancel_descriptor_read\",\"input_sha256\":\"%s\",\"library\":\"%s\",\"expected\":\"rejected_cancelled\",\"observed\":\"%s\",\"cancel_source\":\"separate pthread atomic flag\",\"accepted\":%d,\"error\":\"%s\",\"input_bytes\":%zu,\"bytes_read\":%zu,\"read_callbacks\":%d,\"callbacks_after_observed_cancel\":%d,\"close_calls\":%d,\"elapsed_us\":%lu,\"exit_status\":%d}\n",
      hash,xmlParserVersion,!accepted&&s.reason&&!strcmp(s.reason,"CANCELLED_READ")?"rejected_cancelled":accepted?"accepted":"rejected_other",accepted,s.reason?s.reason:"NONE",n,s.bytes,s.read_calls,s.reads_after_cancel,s.close_count,us,pass?0:1);
    return pass?0:1;
}

static int run_cancel_cleanup(void) {
    static const unsigned char input[]="<r/>"; char hash[65]; sha_hex(input,sizeof(input)-1,hash);
    atomic_int cancel=0, cleanup=0; State s; unsigned long us=0;
    CancelArgs args={&cancel,&cleanup,0}; pthread_t thread;
    if(pthread_create(&thread,NULL,cancel_thread,&args)!=0)return 1;
    int accepted=parse_fd_bytes_ex(input,sizeof(input)-1,&s,0,&cancel,&cleanup,20000,&us);
    pthread_join(thread,NULL);
    int pass=!accepted && s.reason && !strcmp(s.reason,"CANCELLED_CLEANUP") && s.close_count==1;
    printf("{\"case\":\"async_cancel_cleanup\",\"input_sha256\":\"%s\",\"library\":\"%s\",\"expected\":\"rejected_cancelled\",\"observed\":\"%s\",\"cancel_source\":\"separate pthread waits for close callback\",\"accepted\":%d,\"error\":\"%s\",\"close_calls\":%d,\"elapsed_us\":%lu,\"exit_status\":%d}\n",
      hash,xmlParserVersion,!accepted&&s.reason&&!strcmp(s.reason,"CANCELLED_CLEANUP")?"rejected_cancelled":accepted?"accepted":"rejected_other",accepted,s.reason?s.reason:"NONE",s.close_count,us,pass?0:1);
    return pass?0:1;
}

static int run_cpu_worker(void) {
    size_t n=0; unsigned char *data=make_xml("segtext",TEXT_CAP,&n);
    if(!data)return 1;
    char hash[65]; sha_hex(data,n,hash);
    int ready[2]; if(pipe(ready)!=0){free(data);return 1;}
    pid_t child=fork();
    if(child<0){close(ready[0]);close(ready[1]);free(data);return 1;}
    if(child==0){
        close(ready[0]); char mark='R'; (void)write(ready[1],&mark,1); close(ready[1]);
        for(;;){State s; (void)parse_bytes(data,n,&s,0,NULL,NULL);}
    }
    close(ready[1]); char mark=0; ssize_t got=read(ready[0],&mark,1); close(ready[0]);
    if(got!=1 || mark!='R'){kill(child,SIGKILL);waitpid(child,NULL,0);free(data);return 1;}
    usleep(30000);
    double before=now_ms(); int kill_rc=kill(child,SIGTERM); int status=0; struct rusage usage;
    memset(&usage,0,sizeof(usage)); pid_t reaped=wait4(child,&status,0,&usage); double latency=now_ms()-before;
    double cpu_ms=(double)usage.ru_utime.tv_sec*1000.0+(double)usage.ru_utime.tv_usec/1000.0+
                  (double)usage.ru_stime.tv_sec*1000.0+(double)usage.ru_stime.tv_usec/1000.0;
    int pass=kill_rc==0 && reaped==child && WIFSIGNALED(status) && WTERMSIG(status)==SIGTERM && cpu_ms>0.0;
    printf("{\"case\":\"cpu_worker_termination\",\"input_sha256\":\"%s\",\"library\":\"%s\",\"expected\":\"terminated_and_reaped\",\"observed\":\"%s\",\"input_bytes\":%zu,\"signal\":\"SIGTERM\",\"kill_rc\":%d,\"reaped\":%d,\"terminated_by_signal\":%d,\"cpu_ms\":%.3f,\"peak_rss_bytes_darwin\":%ld,\"cancel_to_reap_us\":%.0f,\"worker_output\":\"none\",\"exit_status\":%d}\n",
      hash,xmlParserVersion,pass?"terminated_and_reaped":"unexpected",n,kill_rc,reaped==child,WIFSIGNALED(status)?WTERMSIG(status):0,cpu_ms,usage.ru_maxrss,latency*1000.0,pass?0:1);
    free(data); return pass?0:1;
}

static int run_schema_deny(const char *id, const char *system_id) {
    char schema_text[1024];
    snprintf(schema_text,sizeof(schema_text),
      "<xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema'><xs:include schemaLocation='%s'/></xs:schema>",system_id);
    State s={0};s.fd=-1;char hash[65];sha_hex(schema_text,strlen(schema_text),hash);
    xmlSchemaParserCtxt *ctxt=xmlSchemaNewMemParserCtxt(schema_text,(int)strlen(schema_text));
    if(!ctxt)return 1;
    xmlSchemaSetResourceLoader(ctxt,deny_loader,&s);
    xmlSchemaSetParserErrors(ctxt,quiet_schema_error,quiet_schema_error,&s);
    xmlSchema *schema=xmlSchemaParse(ctxt);
    int pass=s.loader_count==1 && schema==NULL;
    printf("{\"case\":\"%s\",\"input_sha256\":\"%s\",\"expected\":\"deny_one_resource\",\"observed\":\"%s\",\"exit_status\":%d,\"library\":\"%s\",\"loader_calls\":%d,\"network_requests\":0}\n",
      id,hash,pass?"denied":"unexpected",pass?0:1,xmlParserVersion,s.loader_count);
    if(schema)xmlSchemaFree(schema);xmlSchemaFreeParserCtxt(ctxt);return pass?0:1;
}

static int self_test(void) {
    int failures=0; size_t n=0; unsigned char *b;
    struct Case {const char *id,*xml;int ok;} fixed[]={
      {"plain","<r/>",1}, {"doctype_bare","<!DOCTYPE r><r/>",0},
      {"doctype_internal","<!DOCTYPE r [<!ELEMENT r EMPTY>]><r/>",0},
      {"entity_general","<!DOCTYPE r [<!ENTITY e 'x'>]><r>&e;</r>",0},
      {"entity_parameter","<!DOCTYPE r [<!ENTITY % p '<!ELEMENT r EMPTY>'>%p;]><r/>",0},
      {"external_general_file","<!DOCTYPE r [<!ENTITY e SYSTEM 'file:///tmp/ip2a-r3-no-read'>]><r>&e;</r>",0},
      {"external_general_http","<!DOCTYPE r [<!ENTITY e SYSTEM 'http://127.0.0.1:9/no'>]><r>&e;</r>",0},
      {"external_dtd_file","<!DOCTYPE r SYSTEM 'file:///tmp/ip2a-r3-no-read'><r/>",0},
      {"external_dtd_http","<!DOCTYPE r SYSTEM 'http://127.0.0.1:9/no'><r/>",0},
      {"external_parameter_file","<!DOCTYPE r [<!ENTITY % e SYSTEM 'file:///tmp/ip2a-r3-no-read'>%e;]><r/>",0},
      {"external_parameter_http","<!DOCTYPE r [<!ENTITY % e SYSTEM 'http://127.0.0.1:9/no'>%e;]><r/>",0},
      {"malformed","<r><x></r>",0}, {"two_roots","<r/><s/>",0},
      {"trailing_data","<r/>x",0}, {"invalid_encoding","<?xml version='1.0' encoding='UTF-99'?><r/>",0},
      {"wrong_namespace_version_wellformed","<r xmlns='urn:unknown' version='99'/>",1},
      {"schema_hint_inert","<r xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='http://127.0.0.1:9/no.xsd'/>",1},
      {"xinclude_inert","<r xmlns:xi='http://www.w3.org/2001/XInclude'><xi:include href='file:///tmp/ip2a-r3-no-read'/></r>",1},
    };
    for(size_t i=0;i<sizeof(fixed)/sizeof(fixed[0]);i++) failures+=run_one(fixed[i].id,(const unsigned char*)fixed[i].xml,strlen(fixed[i].xml),fixed[i].ok);
    static const unsigned char invalid_utf8[]={ '<','r','>',0xff,'<','/','r','>' };
    failures+=run_one("invalid_utf8",invalid_utf8,sizeof(invalid_utf8),0);
    failures+=run_schema_deny("schema_include_file_denied","file:///tmp/ip2a-r3-never-read.xsd");
    failures+=run_schema_deny("schema_include_http_denied","http://127.0.0.1:9/never-read.xsd");
    b=make_xml("deep",64,&n); failures+=run_one("depth_64",b,n,1);free(b);
    b=make_xml("deep",65,&n); failures+=run_one("depth_65",b,n,0);free(b);
    b=make_xml("deep",10000,&n); failures+=run_one("depth_10000",b,n,0);free(b);
    b=make_xml("attr",4096,&n); failures+=run_one("attribute_4096",b,n,1);free(b);
    b=make_xml("attr",4097,&n); failures+=run_one("attribute_4097",b,n,0);free(b);
    b=make_xml("attrs",64,&n); failures+=run_one("attributes_count_64",b,n,1);free(b);
    b=make_xml("attrs",65,&n); failures+=run_one("attributes_count_65",b,n,0);free(b);
    b=make_xml("text",4096,&n); failures+=run_one("text_4096",b,n,1);free(b);
    b=make_xml("text",4097,&n); failures+=run_one("text_4097",b,n,0);free(b);
    b=make_xml("segtext",TEXT_CAP,&n); failures+=run_one("aggregate_text_exact",b,n,1);free(b);
    b=make_xml("segtext",TEXT_CAP+1u,&n); failures+=run_one("aggregate_text_plus1",b,n,0);free(b);
    b=make_xml("nodes",NODE_CAP-1u,&n); failures+=run_one("elements_exact",b,n,1);free(b);
    b=make_xml("nodes",NODE_CAP,&n); failures+=run_one("elements_plus1",b,n,0);free(b);
    const size_t targets[]={BYTE_CAP-1u,BYTE_CAP,BYTE_CAP+1u};
    for(size_t i=0;i<3;i++){
        b=make_xml("bytes",targets[i],&n);
        failures+=run_fd_one(i==0?"descriptor_bytes_cap_minus1":i==1?"descriptor_bytes_cap_exact":"descriptor_bytes_cap_plus1",
                             b,n,i<2,i<2?targets[i]:BYTE_CAP+1u);
        free(b);
    }
    printf("SUMMARY failures=%d library_version=%s options=0x%x\n",failures,xmlParserVersion,OPTIONS);
    return failures?1:0;
}

static int run_measure(const char *kind, size_t n, size_t repeats) {
    size_t length=0; unsigned char *data=make_xml(kind,n,&length);
    if(!data || repeats==0){free(data);return 64;}
    int expected;
    if(!strcmp(kind,"nodes")) expected=n+1u<=NODE_CAP;
    else if(!strcmp(kind,"segtext")) expected=n<=TEXT_CAP;
    else if(!strcmp(kind,"deep")) expected=n<=DEPTH_CAP;
    else if(!strcmp(kind,"attr") || !strcmp(kind,"text")) expected=n<=VALUE_CAP;
    else {free(data);return 64;}
    char hash[65]; sha_hex(data,length,hash);
    int accepted=0, pass=1; State last={0}; double start=now_ms();
    for(size_t i=0;i<repeats;i++) { accepted=parse_bytes(data,length,&last,0,NULL,NULL); if(accepted!=expected)pass=0; }
    double elapsed=(now_ms()-start)*1000.0; struct rusage usage; memset(&usage,0,sizeof(usage));
    if(getrusage(RUSAGE_SELF,&usage)!=0){free(data);return 1;}
    printf("{\"case\":\"measure_%s_%zu\",\"input_sha256\":\"%s\",\"input_bytes\":%zu,\"repeats\":%zu,\"expected\":\"%s\",\"observed\":\"%s\",\"accepted_last\":%d,\"error\":\"%s\",\"elapsed_us_total\":%.0f,\"peak_rss_bytes_darwin\":%ld,\"rss_scope\":\"whole_harness_process_including_generated_input\",\"exit_status\":%d}\n",
      kind,n,hash,length,repeats,expected?"accepted":"rejected",accepted?"accepted":"rejected",accepted,last.reason?last.reason:"NONE",elapsed,usage.ru_maxrss,pass?0:1);
    free(data); return pass?0:1;
}

int main(int argc,char **argv) {
    if (!xmlParserVersion || strcmp(xmlParserVersion,"21504")) {
        fprintf(stderr,"FATAL expected libxml2 2.15.4; got %s\n",xmlParserVersion?xmlParserVersion:"NULL"); return 70;
    }
    xmlInitParser();
    xmlSetGenericErrorFunc(NULL,quiet_generic_error);
    if (argc==2 && strcmp(argv[1],"self-test")==0) return self_test();
    if (argc==2 && strcmp(argv[1],"cancel-read")==0) return run_cancel_read();
    if (argc==2 && strcmp(argv[1],"cancel-cleanup")==0) return run_cancel_cleanup();
    if (argc==2 && strcmp(argv[1],"cpu-worker")==0) return run_cpu_worker();
    if(argc==5 && strcmp(argv[1],"measure")==0) {
        char *end1=NULL,*end2=NULL; unsigned long long reps=strtoull(argv[3],&end1,10), n=strtoull(argv[4],&end2,10);
        if(!end1 || *end1 || !end2 || *end2 || n==0 || reps==0)return 64;
        return run_measure(argv[2],(size_t)n,(size_t)reps);
    }
    fprintf(stderr,"usage: %s self-test|cancel-read|cancel-cleanup|cpu-worker|measure KIND REPEATS SIZE\n",argv[0]); return 64;
}
