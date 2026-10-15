import Darwin
import Foundation

private let inputLimit = 16 * 1024 * 1024
private let nameLimit = 256

private struct Waypoint {
    let latitude: String
    let longitude: String
    let name: String?
}

private struct Route {
    let version: String
    let name: String?
    let waypoints: [Waypoint]
}

private enum ConverterError: Error, CustomStringConvertible {
    case usage
    case input(String)
    case parse(String)
    case output(String)

    var description: String {
        switch self {
        case .usage:
            return "Usage: rtz-gpx-converter <input.rtz> <output.gpx> [--route-name NAME | --omit-route-name]"
        case .input(let message), .parse(let message), .output(let message):
            return message
        }
    }
}

private final class RTZParser: NSObject, XMLParserDelegate {
    private struct ElementFrame: Equatable {
        let name: String
        let namespaceURI: String
    }

    private let namespaceByVersion = [
        "1.0": "http://www.cirm.org/RTZ/1/0",
        "1.2": "http://www.cirm.org/RTZ/1/2",
    ]

    private var stack: [ElementFrame] = []
    private var version: String?
    private var routeNamespace: String?
    private var routeName: String?
    private var routeInfoCount = 0
    private var waypointsGroupCount = 0
    private var waypoints: [Waypoint] = []
    private var waypointIDs = Set<String>()
    private var currentWaypoint: WaypointBuilder?
    private var parseFailure: String?
    private var sawRoot = false

    private struct WaypointBuilder {
        let name: String?
        var positionCount = 0
        var latitude: String?
        var longitude: String?
    }

    func parse(_ data: Data) throws -> Route {
        // XMLParser has no delegate callback for a bare DOCTYPE (without a declaration).
        // This prototype therefore performs a conservative UTF-8 preflight before parsing.
        guard let text = String(data: data, encoding: .utf8) else {
            throw ConverterError.parse("Prototype DOCTYPE preflight requires UTF-8 XML input.")
        }
        guard !text.contains("<!DOCTYPE") else {
            throw ConverterError.parse("DOCTYPE declarations are not accepted.")
        }

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.shouldResolveExternalEntities = false
        guard parser.parse() else {
            throw ConverterError.parse(parseFailure ?? parser.parserError?.localizedDescription ?? "Malformed or unsafe XML input.")
        }
        guard sawRoot, stack.isEmpty else {
            throw ConverterError.parse("Input did not contain one complete RTZ route.")
        }
        guard routeInfoCount == 1 else {
            throw ConverterError.parse("Input must contain exactly one direct routeInfo element.")
        }
        guard waypointsGroupCount == 1 else {
            throw ConverterError.parse("Input must contain exactly one direct waypoints element.")
        }
        guard !waypoints.isEmpty else {
            throw ConverterError.parse("Input contains no waypoints.")
        }
        guard let version else {
            throw ConverterError.parse("RTZ version is missing or unsupported.")
        }
        return Route(version: version, name: routeName, waypoints: waypoints)
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes: [String: String] = [:]
    ) {
        let name = elementName.isEmpty ? (qName ?? "") : elementName
        let uri = namespaceURI ?? ""
        if stack.isEmpty {
            guard !sawRoot, name == "route" else {
                reject(parser, "Expected one RTZ route root element.")
                return
            }
            sawRoot = true
            guard let declaredVersion = attributes["version"],
                  let expectedNamespace = namespaceByVersion[declaredVersion] else {
                reject(parser, "Unsupported or missing RTZ version; only prototype dialects 1.0 and 1.2 are accepted.")
                return
            }
            guard uri == expectedNamespace else {
                reject(parser, "RTZ version and namespace do not match a supported prototype dialect.")
                return
            }
            version = declaredVersion
            routeNamespace = uri
        } else if uri == routeNamespace {
            let route = ElementFrame(name: "route", namespaceURI: uri)
            let waypointsGroup = ElementFrame(name: "waypoints", namespaceURI: uri)
            let waypoint = ElementFrame(name: "waypoint", namespaceURI: uri)
            switch name {
            case "routeInfo", "waypoints":
                guard stack == [route] else {
                    reject(parser, "RTZ routeInfo and waypoints must be direct route children.")
                    return
                }
            case "waypoint":
                guard stack == [route, waypointsGroup] else {
                    reject(parser, "RTZ waypoint elements are only accepted directly inside RTZ waypoints.")
                    return
                }
            case "position":
                guard stack == [route, waypointsGroup, waypoint] else {
                    reject(parser, "RTZ position elements are only accepted directly inside an RTZ waypoint.")
                    return
                }
            default:
                break
            }
            switch (stack.last?.name, name) {
            case ("route", "routeInfo"):
                routeInfoCount += 1
                guard routeInfoCount == 1 else {
                    reject(parser, "Ambiguous input: more than one routeInfo element.")
                    return
                }
                routeName = attributes["routeName"]
            case ("route", "waypoints"):
                waypointsGroupCount += 1
                guard waypointsGroupCount == 1 else {
                    reject(parser, "Ambiguous input: more than one waypoints element.")
                    return
                }
            case ("waypoints", "waypoint"):
                guard currentWaypoint == nil else {
                    reject(parser, "Ambiguous nested waypoint input.")
                    return
                }
                guard let id = attributes["id"], !id.isEmpty else {
                    reject(parser, "Waypoint is missing its ID.")
                    return
                }
                guard waypointIDs.insert(id).inserted else {
                    reject(parser, "Ambiguous input: waypoint IDs must be unique.")
                    return
                }
                currentWaypoint = WaypointBuilder(name: attributes["name"])
            case ("waypoint", "position"):
                guard currentWaypoint != nil else {
                    reject(parser, "Position appeared outside a waypoint.")
                    return
                }
                currentWaypoint?.positionCount += 1
                guard currentWaypoint?.positionCount == 1 else {
                    reject(parser, "Ambiguous waypoint: more than one position element.")
                    return
                }
                currentWaypoint?.latitude = attributes["lat"]
                currentWaypoint?.longitude = attributes["lon"]
            default:
                break // Other RTZ metadata is intentionally ignored by this prototype.
            }
        }
        stack.append(ElementFrame(name: name, namespaceURI: uri))
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let name = elementName.isEmpty ? (qName ?? "") : elementName
        let uri = namespaceURI ?? ""
        guard stack.last == ElementFrame(name: name, namespaceURI: uri) else {
            reject(parser, "Ambiguous XML element nesting.")
            return
        }
        let rtzNamespace = routeNamespace ?? ""
        let expectedWaypointPath = [
            ElementFrame(name: "route", namespaceURI: rtzNamespace),
            ElementFrame(name: "waypoints", namespaceURI: rtzNamespace),
            ElementFrame(name: "waypoint", namespaceURI: rtzNamespace),
        ]
        if name == "waypoint", uri == routeNamespace,
           stack == expectedWaypointPath, let builder = currentWaypoint {
            guard builder.positionCount == 1,
                  let rawLatitude = builder.latitude,
                  let rawLongitude = builder.longitude else {
                reject(parser, "Each waypoint must have exactly one position with latitude and longitude.")
                return
            }
            do {
                let latitude = try Self.coordinate(rawLatitude, label: "latitude", lower: -90, upper: 90)
                let longitude = try Self.coordinate(rawLongitude, label: "longitude", lower: -180, upper: 180)
                if version == "1.2", longitude == "180" {
                    throw ConverterError.parse("Prototype rejects positive 180 longitude for RTZ 1.2.")
                }
                waypoints.append(Waypoint(latitude: latitude, longitude: longitude, name: builder.name))
            } catch {
                reject(parser, error.localizedDescription)
                return
            }
            currentWaypoint = nil
        }
        stack.removeLast()
    }

    func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
        reject(parser, "DOCTYPE and entity declarations are not accepted.")
    }

    func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
        reject(parser, "DOCTYPE and external entity declarations are not accepted.")
    }

    func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
        reject(parser, "External entity resolution is disabled.")
        return nil
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        if parseFailure == nil { parseFailure = parseError.localizedDescription }
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        if parseFailure == nil { parseFailure = validationError.localizedDescription }
    }

    private func reject(_ parser: XMLParser, _ message: String) {
        if parseFailure == nil { parseFailure = message }
        parser.abortParsing()
    }

    private static func coordinate(_ raw: String, label: String, lower: Decimal, upper: Decimal) throws -> String {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$"#
        guard text.range(of: pattern, options: .regularExpression) != nil,
              let value = Decimal(string: text, locale: Locale(identifier: "en_US_POSIX")),
              !value.isNaN, value >= lower, value <= upper else {
            throw ConverterError.parse("Invalid or out-of-range \(label).")
        }
        return normalizeDecimal(text)
    }

    private static func normalizeDecimal(_ text: String) -> String {
        var source = text
        var negative = false
        if source.first == "+" { source.removeFirst() }
        if source.first == "-" { negative = true; source.removeFirst() }
        let parts = source.split(separator: ".", omittingEmptySubsequences: false)
        var integer = String(parts[0])
        while integer.count > 1 && integer.first == "0" { integer.removeFirst() }
        var fraction = parts.count > 1 ? String(parts[1]) : ""
        while fraction.last == "0" { fraction.removeLast() }
        let isZero = integer.allSatisfy({ $0 == "0" }) && fraction.allSatisfy({ $0 == "0" })
        return (negative && !isZero ? "-" : "") + integer + (fraction.isEmpty ? "" : "." + fraction)
    }
}

private func readBoundedFile(_ path: String) throws -> Data {
    let fd = Darwin.open(path, O_RDONLY | O_CLOEXEC | O_NONBLOCK)
    guard fd >= 0 else { throw ConverterError.input("Cannot open input file (errno \(errno)).") }
    defer { _ = Darwin.close(fd) }

    var info = stat()
    guard Darwin.fstat(fd, &info) == 0 else { throw ConverterError.input("Cannot inspect opened input file.") }
    guard (info.st_mode & S_IFMT) == S_IFREG else { throw ConverterError.input("Input must be a regular file.") }

    let handle = FileHandle(fileDescriptor: fd, closeOnDealloc: false)
    var data = Data()
    while data.count <= inputLimit {
        let remaining = inputLimit + 1 - data.count
        guard let chunk = try handle.read(upToCount: min(64 * 1024, remaining)), !chunk.isEmpty else { break }
        data.append(chunk)
    }
    guard data.count <= inputLimit else { throw ConverterError.input("Input exceeds the prototype limit of 16 MiB.") }
    return data
}

private func validXMLText(_ value: String) -> Bool {
    value.unicodeScalars.allSatisfy { scalar in
        let n = scalar.value
        return n == 0x9 || n == 0xA || n == 0xD || (0x20...0xD7FF).contains(n) ||
            (0xE000...0xFFFD).contains(n) || (0x10000...0x10FFFF).contains(n)
    }
}

private func xmlEscape(_ value: String) -> String {
    value.replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
}

private func effectiveName(source: String?, override: String?, omit: Bool) throws -> String? {
    if omit { return nil }
    let chosen = override ?? source
    guard let name = chosen,
          !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          name.unicodeScalars.count <= nameLimit,
          validXMLText(name) else {
        throw ConverterError.parse("Route name is missing or invalid. Supply --route-name NAME or explicitly pass --omit-route-name.")
    }
    return name
}

private func serialize(_ route: Route, name: String?) -> Data {
    var lines = [
        #"<?xml version="1.0" encoding="UTF-8"?>"#,
        #"<gpx xmlns="http://www.topografix.com/GPX/1/1" version="1.1" creator="RTZ-GPX Converter Prototype">"#,
        "  <rte>",
    ]
    if let name { lines.append("    <name>\(xmlEscape(name))</name>") }
    for waypoint in route.waypoints {
        lines.append("    <rtept lat=\"\(waypoint.latitude)\" lon=\"\(waypoint.longitude)\">")
        if let waypointName = waypoint.name, !waypointName.isEmpty {
            lines.append("      <name>\(xmlEscape(waypointName))</name>")
        }
        lines.append("    </rtept>")
    }
    lines.append("  </rte>")
    lines.append("</gpx>")
    lines.append("")
    return Data(lines.joined(separator: "\n").utf8)
}

private func publishAtomically(_ data: Data, to path: String) throws {
    let destination = URL(fileURLWithPath: path).standardizedFileURL
    let parent = destination.deletingLastPathComponent()
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDirectory), isDirectory.boolValue else {
        throw ConverterError.output("Output directory does not exist.")
    }
    guard !FileManager.default.fileExists(atPath: destination.path) else {
        throw ConverterError.output("Output already exists; choose a new filename.")
    }

    let temporary = parent.appendingPathComponent(".rtz-gpx-\(UUID().uuidString).tmp")
    do {
        try data.write(to: temporary, options: .atomic)
        try FileManager.default.moveItem(at: temporary, to: destination)
    } catch {
        try? FileManager.default.removeItem(at: temporary)
        throw ConverterError.output("Could not publish GPX output: \(error.localizedDescription)")
    }
}

private func run() throws {
    let args = Array(CommandLine.arguments.dropFirst())
    guard args.count >= 2 else { throw ConverterError.usage }
    let input = args[0]
    let output = args[1]
    var override: String?
    var omitName = false
    var index = 2
    while index < args.count {
        switch args[index] {
        case "--route-name":
            guard index + 1 < args.count, override == nil, !omitName else { throw ConverterError.usage }
            override = args[index + 1]
            index += 2
        case "--omit-route-name":
            guard override == nil, !omitName else { throw ConverterError.usage }
            omitName = true
            index += 1
        default:
            throw ConverterError.usage
        }
    }

    let data = try readBoundedFile(input)
    let route = try RTZParser().parse(data)
    let exportName = try effectiveName(source: route.name, override: override, omit: omitName)
    let outputData = serialize(route, name: exportName)
    try publishAtomically(outputData, to: output)
    print("Wrote \(route.waypoints.count) waypoint(s) from RTZ \(route.version).")
}

do {
    try run()
} catch {
    fputs("rtz-gpx-converter: \(error)\n", stderr)
    exit(EXIT_FAILURE)
}
