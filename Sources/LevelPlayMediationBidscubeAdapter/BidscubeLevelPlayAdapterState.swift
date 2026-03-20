#if canImport(IronSource)
import Foundation

/// Shared “loaded” placement tracking (parity with Android `BidscubeLevelPlayState`).
enum BidscubeLevelPlayAdapterState {
    static var loadedInterstitialPlacements = Set<String>()
    static var loadedRewardedPlacements = Set<String>()
}
#endif
