// TradingviewChartView.swift
// Copyright (c) 2021 Joe Blau

import SwiftUI
import WebKit

struct TradingviewChartView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context _: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        return WKWebView(frame: UIScreen.main.bounds,
                         configuration: configuration)
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        switch Bundle.main.url(forResource: "index", withExtension: "html") {
        case let .some(url):
            let themeURL: URL

            switch colorScheme {
            case .dark: themeURL = URL(string: url.absoluteString + "?theme=dark")!
            default: themeURL = URL(string: url.absoluteString + "?theme=light")!
            }

            uiView.loadFileURL(themeURL, allowingReadAccessTo: url)
        case .none:
            fatalError("no index file to load")
        }
    }
}
