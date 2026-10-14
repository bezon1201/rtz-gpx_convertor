import AppKit
import Foundation
import Security
import Darwin

struct Observation: Codable {
    let caseName: String
    let result: String
    let detail: String
}

func identity(_ fd: Int32) -> String? {
    var info = stat()
    guard fstat(fd, &info) == 0 else { return nil }
    return "\(info.st_dev):\(info.st_ino)"
}

func openAndRead(_ url: URL, expectedPayload: Data?) -> (String, String?, Bool?) {
    let fd = url.path.withCString { Darwin.open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW) }
    guard fd >= 0 else { return (errno == EACCES ? "DENIED_EACCES" : errno == ELOOP ? "REJECTED_SYMLINK_ELOOP" : "OPEN_FAILED_\(errno)" , nil, nil) }
    defer { close(fd) }
    guard let id = identity(fd) else { return ("FSTAT_FAILED", nil, nil) }
    var info = stat()
    guard fstat(fd, &info) == 0, (info.st_mode & S_IFMT) == S_IFREG else { return ("REJECTED_NONREGULAR", id, nil) }
    guard info.st_size >= 0 && info.st_size <= 4096 else { return ("REJECTED_SIZE", id, nil) }
    var bytes = [UInt8](repeating: 0, count: 4097)
    let count = Darwin.read(fd, &bytes, 4097)
    guard count >= 0 else { return ("READ_FAILED_\(errno)", id, nil) }
    let matches = expectedPayload.map { Data(bytes.prefix(count)) == $0 }
    return ("READ_OK_\(count)", id, matches)
}

func expectedPayload(for url: URL) -> Data {
    let name = url.lastPathComponent
    let text = name.contains("second") ? "R5 synthetic payload two Ω\n" : "R5 synthetic payload one\n"
    return Data(text.utf8)
}

func helperResult(executable: URL, arguments: [String], input: Data?) -> String {
    let process = Process()
    process.executableURL = executable
    process.arguments = arguments
    let out = Pipe()
    let err = Pipe()
    let inputPipe = Pipe()
    process.standardOutput = out
    process.standardError = err
    if input != nil { process.standardInput = inputPipe }
    do { try process.run() }
    catch { return "HELPER_LAUNCH_FAILED" }
    if let input {
        inputPipe.fileHandleForWriting.write(input)
        try? inputPipe.fileHandleForWriting.close()
    }
    let output = out.fileHandleForReading.readDataToEndOfFile()
    _ = err.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return "exit=\(process.terminationStatus);\(String(decoding: output, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines))"
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.title = "R5 Synthetic File Authority Probe"
            panel.message = "Select one or more synthetic R5 files. No route files are used."
            panel.prompt = "Test Access"
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = true
            guard panel.runModal() == .OK else {
                print("{\"case\":\"native-picker\",\"result\":\"CANCELLED\"}")
                NSApp.terminate(nil)
                return
            }
            let urls = panel.urls
            let helper = Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/R5Receiver")
            var observations: [Observation] = []
            var initialIdentities: [String?] = []
            for (index, url) in urls.enumerated() {
                let scopeStarted = url.startAccessingSecurityScopedResource()
                defer { if scopeStarted { url.stopAccessingSecurityScopedResource() } }
                let payload = expectedPayload(for: url)
                let (senderOutcome, senderID, senderPayloadMatches) = openAndRead(url, expectedPayload: payload)
                initialIdentities.append(senderID)
                observations.append(Observation(caseName: "picker-file-\(index + 1)", result: senderOutcome, detail: "fileURL=\(url.isFileURL); regular-open=\(senderID != nil); payloadMatches=\(String(describing: senderPayloadMatches)); securityScopeStartReturned=\(scopeStarted); nameUnicodeScalarCount=\(url.lastPathComponent.unicodeScalars.count)"))
                guard let senderID else { continue }
                let expectedText = String(decoding: payload, as: UTF8.self)
                let pathResult = helperResult(executable: helper, arguments: ["--path", url.path, "--expected-id", senderID, "--expected-payload", expectedText], input: nil)
                observations.append(Observation(caseName: "cross-process-path-locator-\(index + 1)", result: pathResult, detail: "receiving helper result; path is a locator, not authority"))
                do {
                    let bookmark = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
                    let bookmarkResult = helperResult(executable: helper, arguments: ["--bookmark", "--expected-id", senderID, "--expected-payload", expectedText], input: bookmark)
                    observations.append(Observation(caseName: "cross-process-bookmark-\(index + 1)", result: bookmarkResult, detail: "Foundation bookmark data created with default options from the selected URL and passed over stdin; bookmark scope flavor is not independently classified"))
                } catch {
                    observations.append(Observation(caseName: "cross-process-bookmark-\(index + 1)", result: "BOOKMARK_CREATE_FAILED", detail: "errorType=\(type(of: error))"))
                }
            }
            // The per-file security scopes above have ended. This delayed read observes whether the
            // selected URL remains usable after those balanced scopes were stopped.
            sleep(2)
            for (index, url) in urls.enumerated() {
                let (outcome, id, matches) = openAndRead(url, expectedPayload: expectedPayload(for: url))
                observations.append(Observation(caseName: "same-process-delayed-reacquisition-\(index + 1)", result: outcome, detail: "sameObjectAsInitialRead=\(id != nil && id == initialIdentities[index]); payloadMatches=\(String(describing: matches))"))
            }
            let envelope: [String: Any] = [
                "senderPID": getpid(),
                "senderPPID": getppid(),
                "selectedCount": urls.count,
                "observations": observations.map { ["case": $0.caseName, "result": $0.result, "detail": $0.detail] }
            ]
            if let data = try? JSONSerialization.data(withJSONObject: envelope, options: [.sortedKeys]),
               let text = String(data: data, encoding: .utf8) { print(text) }
            NSApp.terminate(nil)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
