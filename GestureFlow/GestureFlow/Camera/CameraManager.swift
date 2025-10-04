//
//  CameraManager.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-02.
//

import Foundation
import AVFoundation

class CameraManager: NSObject {
    private let captureSession = AVCaptureSession() //does real time campture
    private var deviceInput: AVCaptureDeviceInput? //the media input
    private var videoOutput: AVCaptureVideoDataOutput? //to have access to video frames
    private let systemPreferredCamera = AVCaptureDevice.default(for: .video) //the device that provides streams of media
    private var sessionQueue = DispatchQueue(label: "video.preview.session")
    
    //check if app is authorized to use the camera
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    private var addToPreviewStream: ((CGImage) -> Void)?
    
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage
                )
            }
        }
    }()
    
    override init() {
        super.init()
        
        Task {
            await configureSession()
            await startSession()
        }
    }
    
    private func configureSession() async {
        
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else {
            return
        }
        
        captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        guard captureSession.canAddInput(deviceInput) else {
            print("Not able to add device input")
            return
        }
        
        guard captureSession.canAddOutput(videoOutput) else {
            print("Not able to add video output")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
    }
    
    private func startSession() async {
        
        guard await isAuthorized else {
            return
        }
        
        captureSession.startRunning()
        
    }
    
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else {
            return
        }
        addToPreviewStream?(currentFrame)
    }
}
