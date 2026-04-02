//
//  GestureRecognitionService.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-11-02.
//

import Foundation
import Vision
import CoreML
import CoreGraphics
import CoreImage

final class GestureRecognitionService {
    private let model: VNCoreMLModel
    
    init?() {
        guard let mlModel = try? ASLModel(configuration: .init()).model,
              let vnModel = try? VNCoreMLModel(for: mlModel) else {
            print("failed to load coreML model")
            return nil
        }
        self.model = vnModel
    }
    
    
    func predict(from cgImage: CGImage) async -> String? {
        guard let processed = preprocess(cgImage) else { return nil}
        
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: processed)
        
        do {
            try handler.perform([request])
            guard let results = request.results as? [VNClassificationObservation],
                  let best = results.first else {
                return nil
            }
            
            return "\(best.identifier) \(Int(best.confidence*100))%"
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    

    
    
    func preprocess(_ image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        let side = min(width, height)
        
        let x = (width - side) / 2
        let y = (height - side) / 2
        
        guard let cropped = image.cropping(to: CGRect(x: x, y: y, width: side, height: side)) else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cropped)
        let scale = 224.0 / CGFloat(side)
        let resized = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let context = CIContext()
        return context.createCGImage(resized, from: CGRect(x: 0, y: 0, width: 224, height: 224))
    }
    
}


