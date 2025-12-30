//
//  BackgroundImage.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/29/25.
//

import SwiftUI
import FirebaseRemoteConfig
import Combine

fileprivate struct ArtPrefixConfig {
    static let key = "artPrefix"
    static let defaultValue = "default_"
}

fileprivate final class RemoteConfigManager: ObservableObject {
    static let shared = RemoteConfigManager()

    private let remoteConfig: RemoteConfig

    @Published var artPrefix: String = ArtPrefixConfig.defaultValue

    private init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        // Set default for safety
        remoteConfig.setDefaults([ArtPrefixConfig.key: NSString(string: ArtPrefixConfig.defaultValue)])
        // Try to load any previously activated value
        self.artPrefix = remoteConfig.configValue(forKey: ArtPrefixConfig.key).stringValue
        fetchAndActivate()
    }

    func fetchAndActivate() {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self else { return }
            let value = self.remoteConfig.configValue(forKey: ArtPrefixConfig.key).stringValue
            print("value: \(value)")
            if !value.isEmpty {
                DispatchQueue.main.async {
                    self.artPrefix = value
                }
            }
        }
    }
}

struct BackgroundImage: View {
    let baseName: String
    
    @StateObject private var rcManager = RemoteConfigManager.shared
    
    private func prefixed(_ name: String) -> String { rcManager.artPrefix + name }
    
    // MARK: Remote image URL helper
    // NOTE: Replace <your-bucket> with your actual Firebase Storage bucket name.
    private func remoteURLString(for name: String) -> String {
        // Expecting files named like: artPrefix_weatherCondition.jpg in a public bucket path
        // If you use a different extension or path, adjust here.
        let fileName = baseName + ".png"
        print("filename: \(fileName)")
        // Example: https://firebasestorage.googleapis.com/v0/b/<your-bucket>/o/backgrounds%2F<fileName>?alt=media
        // Store just the path segment in Remote Config if preferred; for now, assume a fixed folder "backgrounds".
        let encoded = ("backgrounds/" + fileName).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        return "https://firebasestorage.googleapis.com/v0/b/weather-girls-2.firebasestorage.app/o/\(encoded)?alt=media"
    }
    
    var body: some View {
        AsyncImage(url: URL(string: remoteURLString(for: baseName)), transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                Color.clear
                    .overlay(
                        Image(baseName)
                            .resizable()
                    )
                    .onAppear {
                        print("AsyncImage phase: .empty (loading started) for", remoteURLString(for: baseName))
                    }
            case .success(let image):
                image
                    .resizable()
                    .onAppear {
                        print("AsyncImage phase: .success (remote image loaded successfully) for", remoteURLString(for: baseName))
                    }
            case .failure(let error):
                Image(baseName)
                    .resizable()
                    .onAppear {
                        print("AsyncImage phase: .failure ->", error.localizedDescription, "for", remoteURLString(for: baseName))
                    }
            @unknown default:
                Image(baseName)
                    .resizable()
                    .onAppear {
                        print("AsyncImage phase: @unknown default for", remoteURLString(for: baseName))
                    }
            }
        }
    }
}

#Preview {
    BackgroundImage(baseName: "default_")
}
