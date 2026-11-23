import Foundation

/// Pulls a direct image, media file, or click URL out of an ad body.
/// Apple TV has no WebKit, so HTML that does not contain one of these cannot be shown.
enum AppleTVCreative {
    static func imageURL(in text: String) -> URL? {
        firstURL(in: text, extensions: ["png", "jpg", "jpeg", "gif", "webp"])
    }

    static func mediaURL(in text: String) -> URL? {
        firstURL(in: text, extensions: ["mp4", "m3u8", "mov"])
    }

    static func clickURL(in text: String, excluding: URL?) -> URL? {
        let pattern = "https?://[^\\s\"'<>]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        for match in regex.matches(in: text, range: range) {
            guard let swiftRange = Range(match.range, in: text) else { continue }
            let raw = String(text[swiftRange]).trimmingCharacters(in: CharacterSet(charactersIn: "\\).,;"))
            guard let url = URL(string: raw), url != excluding else { continue }
            return url
        }
        return nil
    }

    private static func firstURL(in text: String, extensions: [String]) -> URL? {
        let joined = extensions.joined(separator: "|")
        let pattern = "https?://[^\\s\"'<>]+\\.(?:\(joined))(?:\\?[^\\s\"'<>]*)?"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let swiftRange = Range(match.range, in: text) else { return nil }
        return URL(string: String(text[swiftRange]))
    }
}
