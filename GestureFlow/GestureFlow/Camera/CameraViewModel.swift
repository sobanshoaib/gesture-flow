//
//  CameraViewModel.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-04.
//

import Foundation
import CoreImage
import Observation

@Observable
class CameraViewModel {
    var currentFrame: CGImage?
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}


