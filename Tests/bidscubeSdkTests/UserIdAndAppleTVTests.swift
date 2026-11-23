import Testing
import UIKit
@testable import BidscubeSDK

extension bidscubeSdkTests {
    @Test func setUserIdBeforeInitializeIsIgnored() {
        BidscubeSDK.cleanup()
        BidscubeSDK.setUserId("user-early")
        #expect(!BidscubeSDK.isInitialized())
        #expect(BidscubeSDK.getUserId() == nil)
    }

    @Test func userIdIsSentOnAdRequestsAndCanBeReplaced() throws {
        BidscubeSDK.cleanup()
        defer { BidscubeSDK.cleanup() }

        let config = SDKConfig.Builder()
            .enableLogging(false)
            .userId("  publisher-1  ")
            .build()
        BidscubeSDK.initialize(config: config)
        #expect(BidscubeSDK.getUserId() == "  publisher-1  ")
        try expectUserId("  publisher-1  ")

        BidscubeSDK.setUserId("  publisher-2  ")
        #expect(BidscubeSDK.getUserId() == "publisher-2")
        try expectUserId("publisher-2")

        BidscubeSDK.setUserId("   ")
        #expect(BidscubeSDK.getUserId() == nil)
        let cleared = try requestURL()
        let items = URLComponents(url: cleared, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.contains { $0.name == "user_id" } == false)
    }

    private func expectUserId(_ userId: String) throws {
        let url = try requestURL()
        let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "user_id" }?
            .value
        #expect(value == userId)
    }

    private func requestURL() throws -> URL {
        let url = URLBuilder.buildAdRequestURL(
            base: "https://example.test/sdk",
            placementId: "placement-1",
            adType: .image,
            position: .unknown,
            timeoutMs: 1000,
            debug: false,
            includeSKAdNetworks: false
        )
        return try #require(url)
    }
}

struct AppleTVCreativeTests {
    @Test func imageCreativeKeepsQueryAndSeparateClick() {
        let body = #"<img src="https://cdn.example/ad.jpg?w=10"><a href="https://shop.example/go">"#
        let image = AppleTVCreative.imageURL(in: body)
        #expect(image?.absoluteString == "https://cdn.example/ad.jpg?w=10")
        #expect(AppleTVCreative.clickURL(in: body, excluding: image)?.absoluteString == "https://shop.example/go")
    }

    @Test func mediaCreativeFindsDirectFile() {
        let body = "wrapper https://cdn.example/spot.MP4 landing https://example.com/land"
        #expect(AppleTVCreative.mediaURL(in: body)?.absoluteString == "https://cdn.example/spot.MP4")
        let media = AppleTVCreative.mediaURL(in: body)
        #expect(AppleTVCreative.clickURL(in: body, excluding: media)?.absoluteString == "https://example.com/land")
    }

    @Test func htmlWithoutDirectAssetIsNotPlayable() {
        let vast = "<VAST version=\"3.0\"><Ad><InLine><AdSystem>x</AdSystem></InLine></Ad></VAST>"
        #expect(AppleTVCreative.imageURL(in: vast) == nil)
        #expect(AppleTVCreative.mediaURL(in: vast) == nil)
    }

    @Test func userAgentTokensIdentifyAppleTV() {
        #expect(DeviceInfo.cpuToken(for: .tv) == "Apple TV; CPU OS")
        #expect(DeviceInfo.mobileToken(for: .tv) == "")
        #expect(DeviceInfo.cpuToken(for: .pad) == "iPad; CPU OS")
        #expect(DeviceInfo.cpuToken(for: .phone) == "iPhone; CPU iPhone OS")
        #expect(DeviceInfo.mobileToken(for: .phone) == " Mobile/15E148")
    }
}
