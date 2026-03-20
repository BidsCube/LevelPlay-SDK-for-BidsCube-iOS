#if canImport(IronSource)
import Foundation
import UIKit
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomBanner)
public final class ISBidscubeCustomBanner: ISBaseBanner {
    public override func loadAd(with adData: ISAdData, viewController: UIViewController, size: ISBannerSize, delegate: ISBannerAdDelegate) {
        _ = viewController
        _ = size
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToLoadWith(.internal, errorCode: ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }

        let callback = BidscubeBannerLoadCallback()
        callback.delegate = delegate
        let view = BidscubeSDK.getImageAdView(placementId, callback)
        callback.attach(view: view)
    }

    public override func destroyAd(with adData: ISAdData) {
        _ = adData
    }
}
#endif
