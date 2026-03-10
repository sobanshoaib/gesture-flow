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
        
        //Core Graphics Image. representation of image, or bitmap, as raw pixel data, including image color, height, pixel dta
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
    
}
