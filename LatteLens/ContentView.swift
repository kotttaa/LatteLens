//
//  ContentView.swift
//  LatteLens
//
//  Created by 尾崎巧汰 on 2026/07/17.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GalleryView()
                .tabItem {
                    Label("ギャラリー", systemImage: "photo.stack")
                }
                .tag(0)
            
            CaptureView(selectedTab: $selectedTab)
                .tabItem {
                    Label("記録", systemImage: "camera.fill")
                }
                .tag(1)
                
            CommunityFeedView()
                .tabItem {
                    Label("コミュニティ", systemImage: "person.3.fill")
                }
                .tag(2)
                
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "c4a484"))
    }
}

struct SettingsView: View {
    @AppStorage("userName") private var userName = "Latte Artist"
    @AppStorage("communityId") private var communityId = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("プロフィール")) {
                    HStack {
                        Text("表示名")
                        Spacer()
                        TextField("名前を入力", text: $userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(footer: Text("ここで設定した表示名は、コミュニティにラテアートを投稿した際に他のユーザーにも公開されます。")) {
                    EmptyView()
                }
                
                Section(header: Text("コミュニティ"), footer: Text("所属するコミュニティID（合言葉）を入力してください。未設定の場合は、投稿や閲覧ができなくなります（完全プライベート）。")) {
                    HStack {
                        Text("所属ID")
                        Spacer()
                        TextField("合言葉を入力", text: $communityId)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ArtworkStore())
}
