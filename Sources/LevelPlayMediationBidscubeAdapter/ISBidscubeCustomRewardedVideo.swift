#if canImport(IronSource)
import Foundation
import UIKit
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomRewardedVideo)
public final class ISBidscubeCustomRewardedVideo: ISBaseRewardedVideo {
    private var showCallback: BidscubeRewardedShowCallback?
    /// Ready state is per adapter instance. Load does not request a creative.
    private var readyPlacementId: String?

    public override func loadAd(with adData: ISAdData, delegate: ISRewardedVideoAdDelegate) {
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToLoadWith(.internal, errorCode: ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }
        guard BidscubeSDK.isInitialized() else {
            delegate.adDidFailToLoadWith(.internal, errorCode: ISAdapterErrorInternal, errorMessage: "BidscubeSDK is not initialized")
            return
        }

        readyPlacementId = placementId
        DispatchQueue.main.async {
            delegate.adDidLoad()
        }
    }

    public override func isAdAvailable(with adData: ISAdData) -> Bool {
        guard let placementId = bidscubePlacementId(from: adData) else { return false }
        return placementId == readyPlacementId
    }

    public override func showAd(with viewController: UIViewController, adData: ISAdData, delegate: ISRewardedVideoAdDelegate) {
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToShowWithErrorCode(ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }

        guard placementId == readyPlacementId else {
            delegate.adDidFailToShowWithErrorCode(ISAdapterErrorInternal, errorMessage: "Rewarded ad is not ready")
            return
        }

        readyPlacementId = nil
        let callback = BidscubeRewardedShowCallback()
        callback.delegate = delegate
        showCallback = callback
        let present = {
            BidscubeSDK.presentVideoAd(placementId, from: viewController, callback: callback)
        }
        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }
}
#endif
