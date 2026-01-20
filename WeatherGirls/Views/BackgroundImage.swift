//
//  BackgroundImage.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/29/25.
//

import SwiftUI
import FirebaseRemoteConfig
import Combine
import FirebaseStorage

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
            if !value.isEmpty {
                DispatchQueue.main.async {
                    self.artPrefix = value
                }
            }
        }
    }
}

struct BackgroundImage: View {
    // Get a reference to the storage service using the default Firebase App
    let baseName: String
    private let storage = Storage.storage()
    @State private var downloadURL: URL?
    @StateObject private var rcManager = RemoteConfigManager.shared
    
    @State private var status: String = "Idle"
    @State private var imageData: Data?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private func prefixed(_ name: String) -> String { rcManager.artPrefix + name }
    
    /// Computed Firebase storage reference
    private var imageRef: StorageReference {
        let storageRef = storage.reference()
        let fileName = prefixed(baseName) + ".png"
        let ref = storageRef.child("backgrounds/\(fileName)")
        
        //print("HLS: storage ref: \(storageRef.fullPath)")
        //print("HLS: imageRef: \(ref.fullPath)")
        //print("HLS: bucket name: \(ref.bucket)")
        
        return ref
    }
    
    private func loadDownloadURL() async {
        do {
            isLoading = true
            status = "Fetching URL"
            let url = try await imageRef.downloadURL()
            downloadURL = url
        } catch {
            status = "Failure"
            errorMessage = "Failed to fetch download URL: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func downloadImageData() async {
        guard let url = downloadURL else { return }
        do {
            status = "Downloading"
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode), !data.isEmpty {
                imageData = data
                status = "Success"
            } else {
                status = "Failure"
                errorMessage = "Unexpected response or empty data"
            }
        } catch {
            status = "Failure"
            errorMessage = "Failed to download image data: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    var body: some View {
        ZStack {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.clear.ignoresSafeArea()
            }
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView(status == "Fetching URL" ? "Fetching…" : "Downloading…")
                    .tint(.white)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            } else if imageData == nil {
                // Placeholder when not loading and no image yet
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .opacity(0.3)
            }
        }
        .allowsHitTesting(false)
        .task {
            // Sequentially fetch URL then data
            imageData = nil
            errorMessage = nil
            await loadDownloadURL()
            await downloadImageData()
        }
    }
}

#Preview {
    BackgroundImage(baseName: "clear")
}
