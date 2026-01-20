import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    typealias UIViewType = BannerView
    let adUnitID: String
    let adSize: AdSize

    #if DEBUG
    private static let defaultAdUnitID = "ca-app-pub-3940256099942544/2435281174" // Test ID
    #else
    private static let defaultAdUnitID = "ca-app-pub-3940256099942544/2934735716" // Real ID
    #endif

    init(adUnitID: String = AdBannerView.defaultAdUnitID, adSize: AdSize = AdSizeBanner) {
        self.adUnitID = adUnitID
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        //bannerView.rootViewController = topViewController()
        bannerView.delegate = context.coordinator
        bannerView.load(Request())
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
    }

    func makeCoordinator() -> BannerCoordinator {
      return BannerCoordinator(self)
    }
    
    class BannerCoordinator: NSObject, BannerViewDelegate {
        let parent: AdBannerView

        init(_ parent: AdBannerView) {
            self.parent = parent
            super.init()
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {}
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {}
    }
}

extension View {
    /// A helper to pin an ad banner safely at the top or above content, respecting safe areas.
    func adBannerPadded() -> some View {
        self
            .frame(maxWidth: .infinity)
    }
}

#Preview("Ad Banner Preview") {
    VStack(spacing: 12) {
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
        Text("Ad Banner")
            .font(.headline)
        AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2435281174", adSize: AdSizeBanner)
            .frame(width: adSize.size.width, height: adSize.size.height)
    }
}
