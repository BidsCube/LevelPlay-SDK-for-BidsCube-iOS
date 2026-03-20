#if canImport(IronSource)
import Foundation
import UIKit
import IronSource
import BidscubeSDK

// MARK: - Banner

final class BidscubeBannerLoadCallback: NSObject, AdCallback {
    weak var delegate: ISBannerAdDelegate?
    var adView: UIView?
    var finished = false
    var didLoad = false

    func attach(view: UIView) {
        adView = view
        maybeDispatchLoaded()
    }

    private func maybeDispatchLoaded() {
        guard !finished, didLoad, let adView else { return }
        finished = true
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidLoad(adView)
            self?.delegate?.adDidOpen()
        }
    }

    func onAdLoading(_ placementId: String) {}
    func onAdLoaded(_ placementId: String) {
        didLoad = true
        maybeDispatchLoaded()
    }
    func onAdDisplayed(_ placementId: String) {}
    func onAdClicked(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidClick()
        }
    }
    func onAdClosed(_ placementId: String) {}
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        guard !finished else { return }
        finished = true
        let code = errorCode != 0 ? errorCode : ISAdapterErrorInternal
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidFailToLoadWith(.noFill, errorCode: code, errorMessage: errorMessage)
        }
    }
}

// MARK: - Interstitial

final class BidscubeInterstitialLoadCallback: NSObject, AdCallback {
    weak var delegate: ISInterstitialAdDelegate?
    private var finished = false

    func onAdLoading(_ placementId: String) {}
    func onAdLoaded(_ placementId: String) {
        guard !finished else { return }
        finished = true
        BidscubeLevelPlayAdapterState.loadedInterstitialPlacements.insert(placementId)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidLoad()
        }
    }
    func onAdDisplayed(_ placementId: String) {}
    func onAdClicked(_ placementId: String) {}
    func onAdClosed(_ placementId: String) {}
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        guard !finished else { return }
        finished = true
        BidscubeLevelPlayAdapterState.loadedInterstitialPlacements.remove(placementId)
        let code = errorCode != 0 ? errorCode : ISAdapterErrorInternal
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidFailToLoadWith(.noFill, errorCode: code, errorMessage: errorMessage)
        }
    }
}

final class BidscubeInterstitialShowCallback: NSObject, AdCallback {
    weak var delegate: ISInterstitialAdDelegate?

    func onAdLoading(_ placementId: String) {}
    func onAdLoaded(_ placementId: String) {}
    func onAdDisplayed(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidOpen()
        }
    }
    func onAdClicked(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidClick()
        }
    }
    func onAdClosed(_ placementId: String) {
        BidscubeLevelPlayAdapterState.loadedInterstitialPlacements.remove(placementId)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidClose()
        }
    }
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        BidscubeLevelPlayAdapterState.loadedInterstitialPlacements.remove(placementId)
        let code = errorCode != 0 ? errorCode : ISAdapterErrorInternal
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidFailToShowWithErrorCode(code, errorMessage: errorMessage)
        }
    }
}

// MARK: - Rewarded

final class BidscubeRewardedLoadCallback: NSObject, AdCallback {
    weak var delegate: ISRewardedVideoAdDelegate?
    private var finished = false

    func onAdLoading(_ placementId: String) {}
    func onAdLoaded(_ placementId: String) {
        guard !finished else { return }
        finished = true
        BidscubeLevelPlayAdapterState.loadedRewardedPlacements.insert(placementId)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidLoad()
        }
    }
    func onAdDisplayed(_ placementId: String) {}
    func onAdClicked(_ placementId: String) {}
    func onAdClosed(_ placementId: String) {}
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        guard !finished else { return }
        finished = true
        BidscubeLevelPlayAdapterState.loadedRewardedPlacements.remove(placementId)
        let code = errorCode != 0 ? errorCode : ISAdapterErrorInternal
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidFailToLoadWith(.noFill, errorCode: code, errorMessage: errorMessage)
        }
    }
}

final class BidscubeRewardedShowCallback: NSObject, AdCallback {
    weak var delegate: ISRewardedVideoAdDelegate?

    func onAdLoading(_ placementId: String) {}
    func onAdLoaded(_ placementId: String) {}
    func onAdDisplayed(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let delegate = self?.delegate else { return }
            delegate.adDidOpen()
            bidscubeInvokeOptional(delegate, selector: "adDidBecomeVisible")
        }
    }
    func onAdClicked(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidClick()
        }
    }
    func onAdClosed(_ placementId: String) {
        BidscubeLevelPlayAdapterState.loadedRewardedPlacements.remove(placementId)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidClose()
        }
    }
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        BidscubeLevelPlayAdapterState.loadedRewardedPlacements.remove(placementId)
        let code = errorCode != 0 ? errorCode : ISAdapterErrorInternal
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.adDidFailToShowWithErrorCode(code, errorMessage: errorMessage)
        }
    }
    func onVideoAdStarted(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let delegate = self?.delegate else { return }
            bidscubeInvokeOptional(delegate, selector: "adDidStart")
        }
    }
    func onVideoAdCompleted(_ placementId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let delegate = self?.delegate else { return }
            bidscubeInvokeOptional(delegate, selector: "adDidEnd")
            delegate.adRewarded()
        }
    }
}
#endif
