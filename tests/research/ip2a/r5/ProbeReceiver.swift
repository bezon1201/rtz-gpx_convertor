import Foundation
import Security
import Darwin

func sandboxEntitled() -> Bool {
    guard let task = SecTaskCreateFromSelf(kCFAllocatorDefault) else { return false }
    let value = SecTaskCopyValueForEntitlement(task, "com.apple.security.app-sandbox" as CFString, nil)
    return (value as? Bool) == true
}

func boundedRead(_ url: URL, expected: String, expectedPayload: String) -> String {
    let fd = url.path.withCString { Darwin.open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW) }
    guard fd >= 0 else { return "deniedOrFailed=\(errno);sandbox=\(sandboxEntitled());pid=\(getpid());ppid=\(getppid())" }
    defer { close(fd) }
    var info = stat()
    guard fstat(fd, &info) == 0 else { return "FSTAT_FAILED" }
    guard (info.st_mode & S_IFMT) == S_IFREG else { return "REJECTED_NONREGULAR" }
    guard info.st_size >= 0 && info.st_size <= 4096 else { return "REJECTED_SIZE" }
    var buffer = [UInt8](repeating: 0, count: 4097)
    let count = Darwin.read(fd, &buffer, 4097)
    guard count >= 0 else { return "READ_FAILED_\(errno)" }
    let identity = "\(info.st_dev):\(info.st_ino)"
    let content = String(decoding: buffer.prefix(count), as: UTF8.self)
    return "read=\(count);sameObject=\(identity == expected);payloadMatches=\(content == expectedPayload);sandbox=\(sandboxEntitled());pid=\(getpid());ppid=\(getppid())"
}

let args = Array(CommandLine.arguments.dropFirst())
guard let expectedIndex = args.firstIndex(of: "--expected-id"), args.indices.contains(expectedIndex + 1) else {
    print("receiver=INVALID_ARGUMENTS;sandbox=\(sandboxEntitled());pid=\(getpid());ppid=\(getppid())")
    exit(2)
}
let expected = args[expectedIndex + 1]
guard let payloadIndex = args.firstIndex(of: "--expected-payload"), args.indices.contains(payloadIndex + 1) else {
    print("receiver=INVALID_ARGUMENTS;sandbox=\(sandboxEntitled());pid=\(getpid());ppid=\(getppid())")
    exit(2)
}
let expectedPayload = args[payloadIndex + 1]

if args.contains("--path"), let index = args.firstIndex(of: "--path"), args.indices.contains(index + 1) {
    print("carrier=path;\(boundedRead(URL(fileURLWithPath: args[index + 1]), expected: expected, expectedPayload: expectedPayload))")
} else if args.contains("--bookmark") {
    var data = Data()
    while true {
        let piece = FileHandle.standardInput.readData(ofLength: 2048)
        if piece.isEmpty { break }
        data.append(piece)
        if data.count > 65_536 {
            print("carrier=bookmark;rejected=oversize")
            exit(3)
        }
    }
    do {
        var stale = false
        let url = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &stale)
        let started = url.startAccessingSecurityScopedResource()
        defer { if started { url.stopAccessingSecurityScopedResource() } }
        print("carrier=bookmark;stale=\(stale);scopeStart=\(started);\(boundedRead(url, expected: expected, expectedPayload: expectedPayload))")
    } catch {
        print("carrier=bookmark;resolveFailed=true;errorType=\(type(of: error));sandbox=\(sandboxEntitled());pid=\(getpid());ppid=\(getppid())")
        exit(4)
    }
} else {
    print("receiver=INVALID_CARRIER")
    exit(2)
}
