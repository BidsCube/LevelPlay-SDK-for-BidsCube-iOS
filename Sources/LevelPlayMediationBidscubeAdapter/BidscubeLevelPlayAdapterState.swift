#if canImport(IronSource)
import Foundation

/// Thread-safe loaded-placement tracking (parity with Android `BidscubeLevelPlayState`).
enum BidscubeLevelPlayAdapterState {
    private static let lock = NSLock()
    private static var interstitial = Set<String>()
    private static var rewarded = Set<String>()

    static func setInterstitialLoaded(_ placementId: String, loaded: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if loaded {
            interstitial.insert(placementId)
        } else {
            interstitial.remove(placementId)
        }
    }

    static func isInterstitialLoaded(_ placementId: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return interstitial.contains(placementId)
    }

    static func setRewardedLoaded(_ placementId: String, loaded: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if loaded {
            rewarded.insert(placementId)
        } else {
            rewarded.remove(placementId)
        }
    }

    static func isRewardedLoaded(_ placementId: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return rewarded.contains(placementId)
    }
}
#endif
