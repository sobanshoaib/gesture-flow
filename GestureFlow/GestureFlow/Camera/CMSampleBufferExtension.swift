//
//  SampleBufferExtension.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-03.
//

import Foundation
import CoreImage
import AVFoundation

extension CMSampleBuffer {
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}
