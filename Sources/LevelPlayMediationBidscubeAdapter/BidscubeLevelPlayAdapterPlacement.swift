#if canImport(IronSource)
import Foundation
import IronSource

func bidscubePlacementId(from adData: ISAdData) -> String? {
    let key = LevelPlayMediationBidscubeAdapterManifest.placementInstanceKey
    if let configuration = adData.value(forKey: "configuration") as? [String: Any],
       let placementId = configuration[key] as? String,
       !placementId.isEmpty {
        return placementId
    }
    if let placementId = adData.value(forKey: key) as? String,
       !placementId.isEmpty {
        return placementId
    }
    return nil
}
#endif
