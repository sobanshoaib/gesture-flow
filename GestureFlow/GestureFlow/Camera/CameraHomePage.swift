//
//  CameraHomePage.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-04.
//

import SwiftUI

struct CameraHomePage: View {
    @State private var cameraVM = CameraViewModel()
    
    var body: some View {
        CameraView(image: $cameraVM.currentFrame)
    }
}

#Preview {
    CameraHomePage()
}
