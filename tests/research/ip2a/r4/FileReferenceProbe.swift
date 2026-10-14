import Foundation
import Darwin

// Research-only probe. All files are synthetic and live in a fresh temporary directory.
// This is not a production file loader or parser.

struct Result: Codable {
    var name: String
    var outcome: String
    var detail: String
}

func check(_ condition: Bool, _ message: String) throws {
    guard condition else { throw NSError(domain: "ProbeAssertion", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
}

func write(_ value: String, to url: URL) throws {
    try Data(value.utf8).write(to: url, options: .atomic)
}

func openRead(_ url: URL, flags: Int32 = O_RDONLY) throws -> Int32 {
    let fd = url.path.withCString { Darwin.open($0, flags | O_CLOEXEC) }
    guard fd >= 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(errno))]) }
    return fd
}

func readAll(_ fd: Int32) throws -> String {
    guard lseek(fd, 0, SEEK_SET) >= 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    var bytes = [UInt8](repeating: 0, count: 4096)
    let count = Darwin.read(fd, &bytes, bytes.count)
    guard count >= 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    return String(decoding: bytes.prefix(count), as: UTF8.self)
}

func identity(_ fd: Int32) throws -> String {
    var info = stat()
    guard fstat(fd, &info) == 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    return "dev=\(info.st_dev),ino=\(info.st_ino),mode=\(info.st_mode),size=\(info.st_size),mtime=\(info.st_mtimespec.tv_sec).\(info.st_mtimespec.tv_nsec),ctime=\(info.st_ctimespec.tv_sec).\(info.st_ctimespec.tv_nsec)"
}

func objectIdentity(_ fd: Int32) throws -> String {
    var info = stat()
    guard fstat(fd, &info) == 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    return "dev=\(info.st_dev),ino=\(info.st_ino)"
}

func record(_ results: inout [Result], _ name: String, _ body: () throws -> String) {
    do { results.append(Result(name: name, outcome: "PASS", detail: try body())) }
    catch { results.append(Result(name: name, outcome: "OBSERVED_FAILURE", detail: String(describing: error))) }
}

let root = FileManager.default.temporaryDirectory.appendingPathComponent("rtz-ip2a-r4-\(UUID().uuidString)", isDirectory: true)
try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: root) }
var results: [Result] = []

record(&results, "normal-selected-regular-file") {
    let file = root.appendingPathComponent("route synthetic.txt")
    try write("preview-A", to: file)
    let fd = try openRead(file); defer { close(fd) }
    var info = stat()
    guard fstat(fd, &info) == 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    try check((info.st_mode & S_IFMT) == S_IFREG, "selected regular file not classified as regular")
    try check((try readAll(fd)) == "preview-A", "descriptor did not read expected payload")
    return "descriptor is regular and readable=true; dev/inode tuple observed=true; byte count=9"
}

record(&results, "rename-and-same-volume-move") {
    let original = root.appendingPathComponent("before.txt")
    let renamed = root.appendingPathComponent("renamed.txt")
    let movedDir = root.appendingPathComponent("subdir", isDirectory: true)
    try FileManager.default.createDirectory(at: movedDir, withIntermediateDirectories: true)
    try write("move-payload", to: original)
    let fd = try openRead(original); defer { close(fd) }
    let before = try identity(fd)
    let objectBefore = try objectIdentity(fd)
    try FileManager.default.moveItem(at: original, to: renamed)
    try check((try readAll(fd)) == "move-payload", "open descriptor lost file after rename")
    try FileManager.default.moveItem(at: renamed, to: movedDir.appendingPathComponent("moved.txt"))
    try check((try objectIdentity(fd)) == objectBefore, "descriptor identity changed across move")
    try check(!FileManager.default.fileExists(atPath: original.path), "original path unexpectedly still exists")
    try check(FileManager.default.fileExists(atPath: movedDir.appendingPathComponent("moved.txt").path), "moved path missing")
    return "descriptor object identity stable=true; metadata changed after rename/move=\((try identity(fd)) != before); original path exists=false; moved path resolves=yes"
}

record(&results, "foundation-resource-identity-availability") {
    let file = root.appendingPathComponent("resource-id.txt")
    let renamed = root.appendingPathComponent("resource-id-renamed.txt")
    try write("resource-id", to: file)
    let keys: Set<URLResourceKey> = [.fileResourceIdentifierKey, .fileIdentifierKey, .generationIdentifierKey, .isRegularFileKey, .isAliasFileKey]
    let before = try file.resourceValues(forKeys: keys)
    try FileManager.default.moveItem(at: file, to: renamed)
    let after = try renamed.resourceValues(forKeys: keys)
    try check(before.fileResourceIdentifier != nil && after.fileResourceIdentifier != nil, "resource identifier unavailable")
    try check(String(describing: before.fileResourceIdentifier) == String(describing: after.fileResourceIdentifier), "resource identifier changed across local rename")
    try check(before.fileIdentifier != nil && after.fileIdentifier != nil, "file identifier unavailable")
    try check(String(describing: before.fileIdentifier) == String(describing: after.fileIdentifier), "file identifier changed across local rename")
    return "resourceID available=\(before.fileResourceIdentifier != nil), equal after rename=\(String(describing: before.fileResourceIdentifier) == String(describing: after.fileResourceIdentifier)); inode available=\(before.fileIdentifier != nil), equal after rename=\(String(describing: before.fileIdentifier) == String(describing: after.fileIdentifier)); generation available=\(before.generationIdentifier != nil); regular=\(String(describing: before.isRegularFile)); alias=\(String(describing: before.isAliasFile))"
}

record(&results, "replace-path-after-open") {
    let path = root.appendingPathComponent("replace.txt")
    let old = root.appendingPathComponent("old.txt")
    try write("confirmed-preview", to: path)
    let fd = try openRead(path); defer { close(fd) }
    let initialIdentity = try objectIdentity(fd)
    try FileManager.default.moveItem(at: path, to: old)
    try write("replacement", to: path)
    let newFD = try openRead(path); defer { close(newFD) }
    try check((try readAll(fd)) == "confirmed-preview", "opened descriptor did not retain original bytes")
    try check((try readAll(newFD)) == "replacement", "reopened path did not read replacement")
    try check((try objectIdentity(fd)) != (try objectIdentity(newFD)), "replacement unexpectedly reused same device/inode")
    return "open descriptor retained old object=\((try objectIdentity(fd)) == initialIdentity), descriptor bytes=\(try readAll(fd)), reopened path bytes=\(try readAll(newFD)), same identity=\((try objectIdentity(fd)) == (try objectIdentity(newFD)))"
}

record(&results, "same-object-content-change-after-preview") {
    let file = root.appendingPathComponent("mutate.txt")
    try write("confirmed-preview", to: file)
    let fd = try openRead(file); defer { close(fd) }
    let before = try identity(fd)
    let writer = try openRead(file, flags: O_WRONLY | O_TRUNC)
    defer { close(writer) }
    let changed = Array("changed-after-preview".utf8)
    let wrote = changed.withUnsafeBytes { Darwin.write(writer, $0.baseAddress!, $0.count) }
    guard wrote == changed.count else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    let after = try identity(fd)
    try check((try objectIdentity(fd)) == before.components(separatedBy: ",").prefix(2).joined(separator: ","), "device/inode changed during in-place write")
    try check(before != after, "metadata did not reflect in-place write")
    try check((try readAll(fd)) == "changed-after-preview", "open descriptor did not observe in-place write")
    return "same descriptor object retained=\((try objectIdentity(fd)) == before.components(separatedBy: ",").prefix(2).joined(separator: ",")); metadata changed=\(before != after); descriptor reread=\(try readAll(fd))"
}

record(&results, "symlink-selection-and-target-replacement") {
    let target = root.appendingPathComponent("target.txt")
    let other = root.appendingPathComponent("other.txt")
    let link = root.appendingPathComponent("selected-link.txt")
    try write("target-A", to: target); try write("target-B", to: other)
    try FileManager.default.createSymbolicLink(atPath: link.path, withDestinationPath: target.path)
    let selectedFD = try openRead(link); defer { close(selectedFD) }
    let selectedID = try objectIdentity(selectedFD)
    try FileManager.default.removeItem(at: link)
    try FileManager.default.createSymbolicLink(atPath: link.path, withDestinationPath: other.path)
    let reopenedFD = try openRead(link); defer { close(reopenedFD) }
    let noFollow = link.path.withCString { Darwin.open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW) }
    let noFollowError = noFollow < 0 ? String(cString: strerror(errno)) : "unexpectedly opened"
    if noFollow >= 0 { close(noFollow) }
    try check((try objectIdentity(selectedFD)) == selectedID, "selected target descriptor changed")
    try check((try readAll(selectedFD)) == "target-A", "selected target descriptor read different content")
    try check((try readAll(reopenedFD)) == "target-B", "reopened symlink did not follow replacement target")
    try check(noFollow < 0 && errno == ELOOP, "O_NOFOLLOW did not reject symlink with ELOOP")
    return "selected descriptor still old identity=\((try objectIdentity(selectedFD)) == selectedID), bytes=\(try readAll(selectedFD)); reopened link bytes=\(try readAll(reopenedFD)); O_NOFOLLOW result=\(noFollowError)"
}

record(&results, "directory-and-nonregular-classification") {
    let dir = root.appendingPathComponent("directory", isDirectory: true)
    let fifo = root.appendingPathComponent("synthetic.fifo")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    guard mkfifo(fifo.path, 0o600) == 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    let fd = try openRead(dir); defer { close(fd) }
    var info = stat(); guard fstat(fd, &info) == 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    var fifoInfo = stat(); guard lstat(fifo.path, &fifoInfo) == 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    try check((info.st_mode & S_IFMT) == S_IFDIR, "directory was not classified")
    try check((fifoInfo.st_mode & S_IFMT) == S_IFIFO, "FIFO was not classified")
    return "fstat identifies directory=\((info.st_mode & S_IFMT) == S_IFDIR); lstat identifies FIFO without blocking open=\((fifoInfo.st_mode & S_IFMT) == S_IFIFO); both must reject before parsing=true"
}

record(&results, "permission-denial") {
    let file = root.appendingPathComponent("denied.txt")
    try write("private synthetic", to: file)
    try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: file.path)
    defer { try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path) }
    let fd = file.path.withCString { Darwin.open($0, O_RDONLY | O_CLOEXEC) }
    if fd >= 0 { close(fd); throw NSError(domain: "ProbeAssertion", code: 1, userInfo: [NSLocalizedDescriptionKey: "mode 000 unexpectedly allowed read access"]) }
    try check(errno == EACCES, "mode 000 failed with a non-permission error")
    return "open denied for uid=\(getuid()): \(String(cString: strerror(errno))): errno=\(errno)"
}

record(&results, "deleted-source-with-open-descriptor") {
    let file = root.appendingPathComponent("deleted.txt")
    try write("still-open", to: file)
    let fd = try openRead(file); defer { close(fd) }
    try FileManager.default.removeItem(at: file)
    try check(!FileManager.default.fileExists(atPath: file.path), "deleted source path still exists")
    try check((try readAll(fd)) == "still-open", "existing descriptor no longer reads opened object")
    return "path exists=false; existing descriptor bytes=still-open"
}

record(&results, "bookmark-rename-resolution") {
    let file = root.appendingPathComponent("bookmark-source.txt")
    let moved = root.appendingPathComponent("bookmark-renamed.txt")
    try write("bookmark-payload", to: file)
    let data = try file.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
    try FileManager.default.moveItem(at: file, to: moved)
    var stale = false
    let resolved = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &stale)
    try check(stale, "bookmark not marked stale after rename on this host")
    try check(resolved.standardizedFileURL == moved.standardizedFileURL, "bookmark did not resolve to moved file")
    return "stale=\(stale); resolved URL equals moved URL=\(resolved.standardizedFileURL == moved.standardizedFileURL); resolved path exists=\(FileManager.default.fileExists(atPath: resolved.path)); security scope is not asserted by this non-sandboxed probe"
}

record(&results, "bookmark-resolution-after-delete") {
    let file = root.appendingPathComponent("bookmark-deleted.txt")
    try write("deleted-bookmark", to: file)
    let data = try file.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
    try FileManager.default.removeItem(at: file)
    var stale = false
    var resolvedAfterDelete = false
    do {
        _ = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &stale)
        resolvedAfterDelete = true
    } catch { }
    try check(!resolvedAfterDelete, "bookmark unexpectedly resolved after source deletion")
    return "resolution failed after deletion as expected"
}

record(&results, "plain-url-security-scope-call") {
    let file = root.appendingPathComponent("plain-url.txt")
    try write("plain-path", to: file)
    let granted = file.startAccessingSecurityScopedResource()
    if granted { file.stopAccessingSecurityScopedResource() }
    return "startAccessing on ordinary temporary URL returned \(granted); sandbox/capability handoff is not exercised by this unsandboxed command-line probe"
}

record(&results, "security-scoped-bookmark-api-availability") {
    let file = root.appendingPathComponent("scoped-bookmark.txt")
    try write("scoped-bookmark", to: file)
    do {
        let data = try file.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        var stale = false
        let resolved = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &stale)
        let access = resolved.startAccessingSecurityScopedResource()
        if access { resolved.stopAccessingSecurityScopedResource() }
        return "bookmark creation/resolution succeeded; stale=\(stale); startAccessing returned \(access); this unsandboxed process does not establish sandbox-grant transport"
    } catch {
        return "security-scoped bookmark API attempt failed in this unsandboxed context: \(error)"
    }
}

record(&results, "preview-export-reacquisition") {
    let file = root.appendingPathComponent("continuity.txt")
    try write("route-semantics-A", to: file)
    let previewFD = try openRead(file); defer { close(previewFD) }
    let preview = try readAll(previewFD)
    try write("route-semantics-B", to: file)
    let exportFD = try openRead(file); defer { close(exportFD) }
    let export = try readAll(exportFD)
    try check(preview != export, "mutation was not detected by reacquired bytes")
    return "freshly reacquired bytes equivalent to preview=\(preview == export); caller must invalidate confirmation=true"
}

let environment = ProcessInfo.processInfo.operatingSystemVersionString
let report: [String: Any] = [
    "os": environment,
    "architecture": ProcessInfo.processInfo.environment["PROCESSOR_ARCHITECTURE"] ?? "arm64 (host observed by uname)",
    "uid": getuid(),
    "results": try results.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }
]
let output = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
FileHandle.standardOutput.write(output)
FileHandle.standardOutput.write(Data([0x0A]))
if results.contains(where: { $0.outcome == "OBSERVED_FAILURE" }) { exit(1) }
