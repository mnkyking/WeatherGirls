import SwiftUI
import FirebaseStorage

struct BackgroundImageTestView: View {
    let baseName: String
    private let storage = Storage.storage()

    @State private var status: String = "Idle"
    @State private var downloadURL: URL?
    @State private var imageData: Data?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var imageRef: StorageReference {
        let storageRef = storage.reference()
        let fileName = baseName + ".png"
        let ref = storageRef.child("backgrounds/\(fileName)")
        return ref
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("BackgroundImage Test")
                .font(.title2).bold()

            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(status)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if let url = downloadURL {
                Text("URL: \(url.absoluteString)")
                    .font(.footnote)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            if let errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Group {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .bottomTrailing) {
                            Text("\(data.count) bytes")
                                .font(.caption2)
                                .padding(6)
                                .background(.thinMaterial, in: Capsule())
                                .padding(6)
                        }
                } else if isLoading {
                    ProgressView("Loading image data…")
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 120)
                        .opacity(0.3)
                }
            }

            HStack {
                Button("Run Test") { Task { await runTest() } }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { reset() }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .task { await runTest() }
    }

    private var statusColor: Color {
        switch status {
        case "Idle": return .gray
        case "Fetching URL": return .blue
        case "Downloading": return .orange
        case "Success": return .green
        case "Failure": return .red
        default: return .gray
        }
    }

    private func reset() {
        status = "Idle"
        downloadURL = nil
        imageData = nil
        errorMessage = nil
        isLoading = false
    }

    private func runTest() async {
        reset()
        await fetchURL()
        await downloadImageData()
    }

    private func fetchURL() async {
        do {
            status = "Fetching URL"
            let url = try await imageRef.downloadURL()
            downloadURL = url
        } catch {
            status = "Failure"
            errorMessage = "Failed to fetch download URL: \(error.localizedDescription)"
        }
    }

    private func downloadImageData() async {
        guard let url = downloadURL else { return }
        do {
            status = "Downloading"
            isLoading = true
            // Use URLSession to verify the URL returns data
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
}

#Preview {
    // Provide a baseName that exists in your Firebase Storage under backgrounds/<baseName>.png
    BackgroundImageTestView(baseName: "default_")
}
