#if !canImport(WebKit)
import UIKit
import AVFoundation

/// Apple TV has no WebKit. These views play a direct image or media URL from the ad response.
/// HTML creatives fail closed.

public final class ImageAdView: UIView {
    private let imageView = UIImageView()
    private let loadingLabel = UILabel()
    private var placementId = ""
    private weak var callback: AdCallback?
    private var clickURL: URL?

    public init() {
        super.init(frame: .zero)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    public func setPlacementInfo(_ placementId: String, callback: AdCallback?) {
        self.placementId = placementId
        self.callback = callback
    }

    public func loadAdFromURL(_ url: URL) {
        loadingLabel.isHidden = false
        fetch(url) { [weak self] text in
            guard let self else { return }
            guard let imageURL = AppleTVCreative.imageURL(in: text) else {
                self.fail("Apple TV cannot render this HTML creative")
                return
            }
            self.clickURL = AppleTVCreative.clickURL(in: text, excluding: imageURL)
            self.show(imageURL)
        }
    }

    private func configure() {
        backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(loadingLabel)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        isUserInteractionEnabled = true
    }

    private func show(_ url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self, let data, let image = UIImage(data: data) else {
                    self?.fail("Apple TV could not decode the image creative")
                    return
                }
                self.imageView.image = image
                self.loadingLabel.isHidden = true
            }
        }.resume()
    }

    private func fetch(_ url: URL, completion: @escaping (String) -> Void) {
        var request = URLRequest(url: url)
        request.setValue(DeviceInfo.userAgent, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error {
                    self?.fail(error.localizedDescription)
                    return
                }
                guard let data, let text = String(data: data, encoding: .utf8) else {
                    self?.fail("Invalid ad response")
                    return
                }
                completion(text)
            }
        }.resume()
    }

    private func fail(_ message: String) {
        loadingLabel.text = message
        callback?.onAdFailed(placementId, errorCode: Constants.ErrorCodes.invalidResponse, errorMessage: message)
    }

    @objc private func handleTap() {
        callback?.onAdClicked(placementId)
        if let clickURL {
            UIApplication.shared.open(clickURL, options: [:], completionHandler: nil)
        }
    }

    public override var canBecomeFocused: Bool { true }

    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations({
            self.layer.borderWidth = self.isFocused ? 6 : 0
            self.layer.borderColor = UIColor.white.cgColor
        }, completion: nil)
    }

    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select }) {
            handleTap()
            return
        }
        super.pressesEnded(presses, with: event)
    }
}

public final class BannerAdView: UIView {
    private let imageView = UIImageView()
    private var bannerPosition: AdPosition
    private var cornerRadius: CGFloat
    private var bannerWidth: CGFloat = 320
    private var bannerHeight: CGFloat = 50
    private var placementId = ""
    private weak var callback: AdCallback?
    private weak var parentViewController: UIViewController?
    private var isAttachedToScreen = false
    private var clickURL: URL?
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    public init(position: AdPosition = .header, cornerRadius: CGFloat = 0) {
        self.bannerPosition = position
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        applySize()
        configure()
    }

    public required init?(coder: NSCoder) {
        self.bannerPosition = .header
        self.cornerRadius = 0
        super.init(coder: coder)
        applySize()
        configure()
    }

    public func setPlacementInfo(_ placementId: String, callback: AdCallback?) {
        self.placementId = placementId
        self.callback = callback
    }

    public func loadAdFromURL(_ url: URL) {
        var request = URLRequest(url: url)
        request.setValue(DeviceInfo.userAgent, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.callback?.onAdFailed(self.placementId, errorCode: Constants.ErrorCodes.networkError, errorMessage: error.localizedDescription)
                    return
                }
                guard let data, let text = String(data: data, encoding: .utf8),
                      let imageURL = AppleTVCreative.imageURL(in: text) else {
                    self.callback?.onAdFailed(self.placementId, errorCode: Constants.ErrorCodes.invalidResponse, errorMessage: "Apple TV cannot render this HTML creative")
                    return
                }
                self.clickURL = AppleTVCreative.clickURL(in: text, excluding: imageURL)
                URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                    DispatchQueue.main.async {
                        guard let data, let image = UIImage(data: data) else { return }
                        self.imageView.image = image
                    }
                }.resume()
            }
        }.resume()
    }

    public func setBannerDimensions(width: CGFloat, height: CGFloat) {
        bannerWidth = width
        bannerHeight = height
        widthConstraint?.constant = width
        heightConstraint?.constant = height
    }

    public func setBannerPosition(_ position: AdPosition) {
        bannerPosition = position
    }

    public func setCornerRadius(_ radius: CGFloat) {
        cornerRadius = radius
        layer.cornerRadius = radius
    }

    public func attachToScreen(in viewController: UIViewController) {
        guard !isAttachedToScreen else { return }
        parentViewController = viewController
        isAttachedToScreen = true
        viewController.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [
            widthAnchor.constraint(equalToConstant: bannerWidth),
            heightAnchor.constraint(equalToConstant: bannerHeight)
        ]
        widthConstraint = constraints[0]
        heightConstraint = constraints[1]
        let parent = viewController.view!
        switch bannerPosition {
        case .header:
            constraints += [
                topAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.topAnchor),
                centerXAnchor.constraint(equalTo: parent.centerXAnchor)
            ]
        case .footer:
            constraints += [
                bottomAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.bottomAnchor),
                centerXAnchor.constraint(equalTo: parent.centerXAnchor)
            ]
        case .sidebar:
            constraints += [
                trailingAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.trailingAnchor),
                centerYAnchor.constraint(equalTo: parent.centerYAnchor)
            ]
        default:
            constraints += [
                centerXAnchor.constraint(equalTo: parent.centerXAnchor),
                centerYAnchor.constraint(equalTo: parent.centerYAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }

    public func detachFromScreen() {
        guard isAttachedToScreen else { return }
        removeFromSuperview()
        isAttachedToScreen = false
        parentViewController = nil
        BidscubeSDK.untrackBanner(self)
    }

    private func applySize() {
        switch bannerPosition {
        case .header, .footer:
            bannerHeight = 50
            bannerWidth = UIScreen.main.bounds.width
        case .sidebar:
            bannerHeight = 250
            bannerWidth = 120
        default:
            bannerHeight = 50
            bannerWidth = 320
        }
    }

    private func configure() {
        backgroundColor = .black
        layer.cornerRadius = cornerRadius
        clipsToBounds = cornerRadius > 0
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        isUserInteractionEnabled = true
    }

    public override var canBecomeFocused: Bool { true }

    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select }) {
            callback?.onAdClicked(placementId)
            if let clickURL {
                UIApplication.shared.open(clickURL, options: [:], completionHandler: nil)
            }
            return
        }
        super.pressesEnded(presses, with: event)
    }
}

public final class VideoAdView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var endObserver: NSObjectProtocol?
    private var placementId = ""
    private weak var callback: AdCallback?
    private weak var parentViewController: UIViewController?
    private var clickURL: URL?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        isUserInteractionEnabled = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
        isUserInteractionEnabled = true
    }

    public func setPlacementInfo(_ placementId: String, callback: AdCallback?) {
        self.placementId = placementId
        self.callback = callback
    }

    public func setParentViewController(_ viewController: UIViewController?) {
        parentViewController = viewController
    }

    public func cleanup() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    public func loadVideoAdFromURL(_ url: URL) {
        var request = URLRequest(url: url)
        request.setValue(DeviceInfo.userAgent, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.callback?.onAdFailed(self.placementId, errorCode: Constants.ErrorCodes.networkError, errorMessage: error.localizedDescription)
                    return
                }
                guard let data, let text = String(data: data, encoding: .utf8),
                      let mediaURL = AppleTVCreative.mediaURL(in: text) else {
                    self.callback?.onAdFailed(self.placementId, errorCode: Constants.ErrorCodes.invalidResponse, errorMessage: "Apple TV video needs a direct mp4 or m3u8 URL. VAST/IMA is iOS-only.")
                    return
                }
                self.clickURL = AppleTVCreative.clickURL(in: text, excluding: mediaURL)
                self.play(mediaURL)
            }
        }.resume()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    public func showCloseButton() {
        (parentViewController as? AdViewController)?.showCloseButton()
    }

    public func showCloseButtonOnComplete() {
        (parentViewController as? AdViewController)?.showCloseButtonOnComplete()
    }

    public func hideCloseButton() {
        (parentViewController as? AdViewController)?.hideCloseButton()
    }

    private func play(_ url: URL) {
        cleanup()
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        let layer = AVPlayerLayer(player: player)
        layer.frame = bounds
        layer.videoGravity = .resizeAspect
        self.layer.addSublayer(layer)
        self.player = player
        self.playerLayer = layer
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.callback?.onVideoAdCompleted(self.placementId)
        }
        callback?.onAdLoaded(placementId)
        callback?.onAdDisplayed(placementId)
        callback?.onVideoAdStarted(placementId)
        player.play()
    }

    public override var canBecomeFocused: Bool { true }

    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select }) {
            callback?.onAdClicked(placementId)
            if let clickURL {
                UIApplication.shared.open(clickURL, options: [:], completionHandler: nil)
            }
            return
        }
        super.pressesEnded(presses, with: event)
    }
}
#endif
