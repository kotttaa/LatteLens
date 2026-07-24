import SwiftUI
import PhotosUI

struct CaptureView: View {
    @EnvironmentObject var store: ArtworkStore
    @Binding var selectedTab: Int
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var pattern: LattePattern = .heart
    @State private var drink: DrinkType = .latte
    @State private var showCamera = false
    @State private var isFromCamera = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Container
                    if let image = selectedImage {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .cornerRadius(16)
                                .clipped()
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        selectedImage = nil
                                        selectedItem = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(Color.white.opacity(0.9))
                                            .background(Circle().fill(Color.black.opacity(0.5)).frame(width: 24, height: 24))
                                    }
                                    .padding(12)
                                }
                            
                            // Re-select / change buttons
                            HStack(spacing: 8) {
                                Button {
                                    isFromCamera = true
                                    showCamera = true
                                } label: {
                                    Image(systemName: "camera.fill")
                                        .padding(10)
                                        .background(.black.opacity(0.6))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    Image(systemName: "photo.fill")
                                        .padding(10)
                                        .background(.black.opacity(0.6))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(12)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(Color(hex: "c4a484"))
                            
                            Text("写真を撮影するか、ライブラリから選択")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 20) {
                                Button {
                                    isFromCamera = true
                                    showCamera = true
                                } label: {
                                    Label("カメラ起動", systemImage: "camera")
                                        .fontWeight(.bold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "c4a484"))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    Label("ライブラリ", systemImage: "photo.on.rectangle")
                                        .fontWeight(.bold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(white: 0.15))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(white: 0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                    }
                    
                    // Metadata selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ラテアートの情報")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Pattern Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("柄（デザイン）")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Picker("柄", selection: $pattern) {
                                ForEach(LattePattern.allCases) { item in
                                    Text(item.localizedName).tag(item)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(white: 0.12))
                            .cornerRadius(12)
                            .accentColor(Color(hex: "c4a484"))
                        }
                        
                        // Drink Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ドリンクタイプ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Picker("ドリンク", selection: $drink) {
                                ForEach(DrinkType.allCases) { item in
                                    Text(item.localizedName).tag(item)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(white: 0.12))
                            .cornerRadius(12)
                            .accentColor(Color(hex: "c4a484"))
                        }
                    }
                    .padding(.top, 10)
                    
                    // Save Button
                    Button {
                        if let image = selectedImage {
                            store.addArtwork(pattern: pattern, drink: drink, image: image)
                            
                            // Save to Photos app if taken with camera
                            if isFromCamera {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                            
                            // Reset state
                            selectedImage = nil
                            selectedItem = nil
                            pattern = .heart
                            drink = .latte
                            // Switch back to gallery tab
                            selectedTab = 0
                        }
                    } label: {
                        Text("ラテアートを保存")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedImage == nil ? Color.gray : Color(hex: "c4a484"))
                            .cornerRadius(28)
                    }
                    .disabled(selectedImage == nil)
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("新しい記録")
            .background(Color.black.ignoresSafeArea())
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            isFromCamera = false
                            selectedImage = uiImage
                        }
                    }
                }
            }
        }
    }
}
