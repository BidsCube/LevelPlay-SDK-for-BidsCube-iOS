#if canImport(IronSource)
import Foundation
import IronSource

struct BidscubeLevelPlayServerParams {
    let placementId: String?
    let requestAuthority: String?
    let sspHost: String?
    let statsAuthority: String?
    let hasReservedOpenRtbParams: Bool

    static func from(_ adData: ISAdData) -> BidscubeLevelPlayServerParams {
        let placementId = bidscubePlacementId(from: adData)
        let configuration = adData.value(forKey: "configuration") as? [String: Any] ?? [:]

        func string(_ key: String) -> String? {
            let value = configuration[key] as? String ?? adData.value(forKey: key) as? String
            guard let value, !value.isEmpty else { return nil }
            return value
        }

        let openRtbKeys = [
            "openrtb_pod_metadata_enabled",
            "video_pod_duration_validation_mode",
            "video_pod_skip_policy",
            "video_pod_continue_on_slot_error",
            "video_pod_show_counter",
        ]
        let hasOpenRtb = openRtbKeys.contains { string($0) != nil }
        if hasOpenRtb {
            NSLog("BidscubeLevelPlay: OpenRTB server parameters are reserved; native OpenRTB 2.6 response parsing is not implemented yet.")
        }
        let requestAuthority = string("request_authority")
        let sspHost = string("ssp_host")
        let statsAuthority = string("stats_authority")
        if requestAuthority != nil || sspHost != nil || statsAuthority != nil {
            NSLog("BidscubeLevelPlay: request_authority / ssp_host / stats_authority parsed but not applied yet.")
        }

        return BidscubeLevelPlayServerParams(
            placementId: placementId,
            requestAuthority: requestAuthority,
            sspHost: sspHost,
            statsAuthority: statsAuthority,
            hasReservedOpenRtbParams: hasOpenRtb
        )
    }
}

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
