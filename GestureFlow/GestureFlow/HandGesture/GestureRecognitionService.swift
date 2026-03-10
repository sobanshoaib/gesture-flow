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
        let request = VNCoreMLRequest(model: model)
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try handler.perform([request])
            guard let results = request.results as? [VNClassificationObservation],
                  let best = results.first else {
                return nil
            }
            
            return "\(best.identifier) \((Int(best.confidence*100)))%"
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    
}


