#if canImport(IronSource)
import Foundation
import IronSource
import BidscubeSDK

/// Reward at most once per show, only after video completion.
final class BidscubeRewardedRewardGuard {
    private var videoCompleted = false
    private var didReward = false
    private var invalidated = false

    func onVideoCompleted() {
        videoCompleted = true
    }

    func onVideoSkipped() {
        invalidated = true
    }

    func onShowFailed() {
        invalidated = true
    }

    func onClosedBeforeCompletion() {
        invalidated = true
    }

    func maybeReward(_ delegate: ISRewardedVideoAdDelegate?) {
        guard let delegate, !invalidated, !didReward, videoCompleted else { return }
        didReward = true
        DispatchQueue.main.async {
            delegate.adRewarded()
        }
    }
}
#endif
