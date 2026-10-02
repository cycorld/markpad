import Foundation

/// A semantic version representation following SemVer 2.0.0.
public struct SemanticVersion: Comparable, Equatable, CustomStringConvertible, Codable, Sendable {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let prerelease: String?
    public let buildMetadata: String?

    public init(major: Int, minor: Int, patch: Int, prerelease: String? = nil, buildMetadata: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.buildMetadata = buildMetadata
    }

    /// Parses a semantic version string (e.g. "0.2.2", "v0.3.0", "1.0.0-beta.1+20261002").
    public init?(_ rawString: String) {
        var str = rawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("v") || str.hasPrefix("V") {
            str.removeFirst()
        }
        guard !str.isEmpty else { return nil }

        // Build metadata separated by '+'
        let buildParts = str.split(separator: "+", maxSplits: 1, omittingEmptySubsequences: false)
        let build = buildParts.count > 1 ? String(buildParts[1]) : nil
        let withoutBuild = String(buildParts[0])

        // Prerelease separated by '-'
        let preParts = withoutBuild.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        let prerelease = preParts.count > 1 ? String(preParts[1]) : nil
        let core = String(preParts[0])

        let numbers = core.split(separator: ".").compactMap { Int($0) }
        guard !numbers.isEmpty else { return nil }

        self.major = numbers[0]
        self.minor = numbers.count > 1 ? numbers[1] : 0
        self.patch = numbers.count > 2 ? numbers[2] : 0
        self.prerelease = prerelease
        self.buildMetadata = build
    }

    public var description: String {
        var result = "\(major).\(minor).\(patch)"
        if let prerelease {
            result += "-\(prerelease)"
        }
        if let buildMetadata {
            result += "+\(buildMetadata)"
        }
        return result
    }

    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }

        switch (lhs.prerelease, rhs.prerelease) {
        case let (.some(l), .some(r)):
            return comparePrerelease(l, r)
        case (.some, .none):
            // Normal version has higher precedence than prerelease
            return true
        case (.none, .some):
            return false
        case (.none, .none):
            return false
        }
    }

    private static func comparePrerelease(_ lhs: String, _ rhs: String) -> Bool {
        let lParts = lhs.split(separator: ".")
        let rParts = rhs.split(separator: ".")
        for (l, r) in zip(lParts, rParts) {
            if l == r { continue }
            if let lInt = Int(l), let rInt = Int(r) {
                return lInt < rInt
            }
            if Int(l) != nil { return true }
            if Int(r) != nil { return false }
            return l < r
        }
        return lParts.count < rParts.count
    }
}
