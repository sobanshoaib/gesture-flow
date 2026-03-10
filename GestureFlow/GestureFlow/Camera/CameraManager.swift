//
//  CameraManager.swift
//  GestureFlow
//
//  Created by Soban Shoaib on 2025-10-02.
//

import Foundation
import AVFoundation

class CameraManager: NSObject {
    private let captureSession = AVCaptureSession() //does real time campture. director/central hub of camera setupt. connects input to output
    private var deviceInput: AVCaptureDeviceInput? //session cannot connect directly to the device (avcapturedevice). avcapturedeviceinput acts like an adapter to connect capturesession and capturedevice.
    private var videoOutput: AVCaptureVideoDataOutput? //what you want to get as output, so in this code it will be a video frame
    private let systemPreferredCamera = AVCaptureDevice.default(for: .video) //the hadware device. device/physical camera that provides streams of media
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
                continuation.yield(cgImage)
            }
        }
    }()
    
    override init() {
        super.init()
        
        //configure and start are async functions, so need to include it in Task. these work in the background
        Task {
            await configureSession()
            await startSession()
        }
    }
    
    private func configureSession() async {
        
        //does 3 checks, checks if user permission is needed, checks device is available, and check if input can be created
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else {
            return
        }
        
        captureSession.beginConfiguration()
        
        //run this when function ends
        defer {
            self.captureSession.commitConfiguration()
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        self.videoOutput = videoOutput
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
        
        if let connection = videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
    }
    
    private func startSession() async {
        
        guard await isAuthorized else {
            return
        }
        
        captureSession.startRunning()
        
    }
    
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    //camera gives frame (output). recieveing one cmsamplebuffer per frame, which is a chunck of raw video data
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else {
            return
        }
        addToPreviewStream?(currentFrame)
    }
}
