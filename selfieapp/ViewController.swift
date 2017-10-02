//
//  ViewController.swift
//  selfieapp
//
//  Created by Sean Berry on 9/25/17.
//  Copyright © 2017 Sean Berry. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    
    private var cameraDevice:AVCaptureDevice?
    private var sessionQueue = DispatchQueue(label: "com.example.session_access_queue")
    private var session:AVCaptureSession!
    private var stillCameraOutput:AVCaptureStillImageOutput!
    
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    @IBAction func takeScreenshot(_ sender: Any) {
        guard let videoConnection = stillCameraOutput.connection(with: .video) else {
            return
        }
        self.stillCameraOutput.captureStillImageAsynchronously(from: videoConnection) { buffer, error in
            guard let buff = buffer else {
                return
            }
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buff)
            if let data = imageData, let i = UIImage(data: data) {
                DispatchQueue.main.async {
                    let faceVC = FaceViewController.create(i)
                    self.navigationController?.pushViewController(faceVC, animated: false)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSession()
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRunning()
    }
    
    func initializeSession() {
        session = AVCaptureSession()
        session.sessionPreset = .photo
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted:Bool) -> Void in
                if granted {
                    self.configureSession()
                }
                else {
                    self.showAccessDeniedMessage()
                }
            }
        case .authorized:
            configureSession()
        case .denied, .restricted:
            showAccessDeniedMessage()
        }
    }
    
    func showAccessDeniedMessage() {
        let alert = UIAlertController(title: "Need Camera Access", message: "This is a selfie app...", preferredStyle: .alert)
        present(alert, animated: false, completion: nil)
    }
    
    func configureSession() {
        configureDeviceInput()
        configureStillImageCameraOutput()
    }
    
    func configureDeviceInput() {
        performConfiguration { () -> Void in
            let availableCameraDevices = AVCaptureDevice.devices(for: .video)
            for device in availableCameraDevices {
                if device.position == .front {
                    self.cameraDevice = device
                }
            }
            
            if let front = self.cameraDevice {
                do {
                    let input = try AVCaptureDeviceInput(device: front)
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                    }
                } catch { }
            }
        }
    }
    
    func configureStillImageCameraOutput() {
        performConfiguration { () -> Void in
            self.stillCameraOutput = AVCaptureStillImageOutput()
            self.stillCameraOutput.outputSettings = [
                AVVideoCodecKey  : AVVideoCodecJPEG,
                AVVideoQualityKey: 0.9
            ]
            
            if self.session.canAddOutput(self.stillCameraOutput) {
                self.session.addOutput(self.stillCameraOutput)
            }
        }
    }
    
    func startRunning() {
        performConfiguration {
            self.session.startRunning()
        }
    }

    func stopRunning() {
        performConfiguration {
            self.session.stopRunning()
        }
    }
    
    func performConfiguration(block: @escaping (() -> Void)) {
        sessionQueue.async() {
            block()
        }
    }
}
