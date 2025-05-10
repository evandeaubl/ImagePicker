//
// Copyright (c) 2025 Evan Deaubl. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import ImagePicker

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First tab - Single Image Picker
            SingleImageView()
            .tabItem {
                Label("Single Image", systemImage: "photo")
            }
            .tag(0)
            
            // Second tab - Image Grid
            ImageGridView()
            .tabItem {
                Label("Image Grid", systemImage: "square.grid.2x2")
            }
            .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
