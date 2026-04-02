//
//  CameraViewModel.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-04.
//

import Foundation
import CoreImage
import Observation
import UIKit

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
    
    func testStaticImage() async {
        guard let uiImage = UIImage(named: "S_test") else {
            print("Could not load testA from assets")
            return
        }

        guard let cgImage = uiImage.cgImage else {
            print("Could not convert UIImage to CGImage")
            return
        }

        if let prediction = await recognizer?.predict(from: cgImage) {
            await MainActor.run {
                self.prediction = prediction
                self.currentFrame = cgImage
            }
            print("Static image prediction:", prediction)
        } else {
            print("No prediction for static image")
        }
    }
    
    
}


