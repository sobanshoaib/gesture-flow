//
//  CameraView.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-02.
//

import SwiftUI
import CoreImage

struct CameraView: View {
    @Binding var image: CGImage?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                ContentUnavailableView("No Camera Feed.", systemImage: "xmark.circle.fill")
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
