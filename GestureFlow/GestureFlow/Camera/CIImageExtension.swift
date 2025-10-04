//
//  CIImageExtension.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-03.
//

import Foundation
import CoreImage

extension CIImage {
    
    var cgImage: CGImage? {
        let ciContext = CIContext()
        
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
    
}
