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
    var prediction: String = ""
    
    private let cameraManager = CameraManager()
    private let recognizer = GestureRecognitionService()
    
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
            
            if let prediction = await recognizer?.predict(from: image) {
                await MainActor.run { self.prediction = prediction}
            }
        }
    }
}


