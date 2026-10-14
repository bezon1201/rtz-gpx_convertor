import Foundation
import Security
import Darwin

func entitlement(_ key: String) -> String {
    guard let task = SecTaskCreateFromSelf(kCFAllocatorDefault),
          let value = SecTaskCopyValueForEntitlement(task, key as CFString, nil) else { return "unavailable" }
    return String(describing: value)
}

func emit(_ text: String, status: Int32 = 0) -> Never {
    print(text)
    exit(status)
}

let args = Array(CommandLine.arguments.dropFirst())
func values(after flag: String) -> [String] {
    args.indices.compactMap { index in
        args[index] == flag && args.indices.contains(index + 1) ? args[index + 1] : nil
    }
}

let header = "pid=\(getpid());ppid=\(getppid());uid=\(getuid());appSandbox=\(entitlement("com.apple.security.app-sandbox"));inherit=\(entitlement("com.apple.security.inherit"));userSelectedReadOnly=\(entitlement("com.apple.security.files.user-selected.read-only"))"
let paths = values(after: "--path")
let expectedIDs = values(after: "--expected-id")
guard !paths.isEmpty else { emit("\(header);result=missing-path", status: 2) }

if let gate = values(after: "--gate").first {
    while access(gate, F_OK) != 0 { usleep(10_000) }
}

for (index, path) in paths.enumerated() {
    let descriptor = path.withCString { open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK) }
    guard descriptor >= 0 else {
        print("\(header);case=open;errno=\(errno);opened=false")
        continue
    }
    defer { close(descriptor) }
    var info = stat()
    guard fstat(descriptor, &info) == 0 else {
        print("\(header);case=fstat;errno=\(errno);opened=true")
        continue
    }
    guard (info.st_mode & S_IFMT) == S_IFREG else {
        print("\(header);case=nonregular;opened=true;regular=false")
        continue
    }
    guard info.st_size >= 0 && info.st_size <= 4096 else {
        print("\(header);case=size;opened=true;regular=true;sizeAllowed=false")
        continue
    }
    var buffer = [UInt8](repeating: 0, count: 4097)
    let count = read(descriptor, &buffer, buffer.count)
    if count < 0 {
        print("\(header);case=read;errno=\(errno);opened=true;regular=true")
    } else {
        let observedID = "\(info.st_dev):\(info.st_ino)"
        let identityMatches = expectedIDs.indices.contains(index) ? String(expectedIDs[index] == observedID) : "not-requested"
        print("\(header);case=read;opened=true;regular=true;bytes=\(count);identityMatches=\(identityMatches)")
    }
}
