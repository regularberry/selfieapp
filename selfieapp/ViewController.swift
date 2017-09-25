//
//  ViewController.swift
//  selfieapp
//
//  Created by Sean Berry on 9/25/17.
//  Copyright © 2017 Sean Berry. All rights reserved.
//

import UIKit
import AVFoundation

protocol DisplaysSensitiveData {
    func hideSensitiveData()
    func showSensitiveData()
}

class ViewController: UIViewController, DisplaysSensitiveData {

    @IBOutlet weak var previewView: UIView!
    private var currentCameraDevice:AVCaptureDevice?
    
    private var sessionQueue = DispatchQueue(label: "com.example.session_access_queue")
    
    private var session:AVCaptureSession!
    private var backCameraDevice:AVCaptureDevice?
    private var frontCameraDevice:AVCaptureDevice?
    private var stillCameraOutput:AVCaptureStillImageOutput!
    private var videoOutput:AVCaptureVideoDataOutput!
    private var metadataOutput:AVCaptureMetadataOutput!
    
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initializeSession()
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
    func configureSession() {
        configureDeviceInput()
        configureStillImageCameraOutput()
        configureFaceDetection()
    }
    
    func configureDeviceInput() {
        
        performConfiguration { () -> Void in
            
            let availableCameraDevices = AVCaptureDevice.devices(for: .video)
            for device in availableCameraDevices {
                if device.position == .back {
                    self.backCameraDevice = device
                }
                else if device.position == .front {
                    self.frontCameraDevice = device
                }
            }
            
            if let front = self.frontCameraDevice {
                self.currentCameraDevice = front
                do {
                    let input = try AVCaptureDeviceInput(device: front)
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                    }
                } catch {
                    
                }
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
    
    
    func configureVideoOutput() {
        performConfiguration { () -> Void in
            self.videoOutput = AVCaptureVideoDataOutput()
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
        }
    }
    
    
    func configureFaceDetection() {
        performConfiguration { () -> Void in
            self.metadataOutput = AVCaptureMetadataOutput()
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: self.sessionQueue)
            
            if self.session.canAddOutput(self.metadataOutput) {
                self.session.addOutput(self.metadataOutput)
            }
            
            if self.metadataOutput.availableMetadataObjectTypes.contains(.face) {
                self.metadataOutput.metadataObjectTypes = [.face]
            }
        }
    }
    
    func performConfiguration(block: @escaping (() -> Void)) {
        sessionQueue.async() { () -> Void in
            block()
        }
    }
    
    func performConfigurationOnCurrentCameraDevice(block: @escaping ((_ currentDevice:AVCaptureDevice) -> Void)) {
        if let currentDevice = self.currentCameraDevice {
            performConfiguration { () -> Void in
                do {
                    try currentDevice.lockForConfiguration()
                    block(currentDevice)
                    currentDevice.unlockForConfiguration()
                } catch {
                    
                }
            }
        }
    }

    func hideSensitiveData() {
    }
    
    func showSensitiveData() {
    }
    
    func startRunning() {
        performConfiguration { () -> Void in
            self.session.startRunning()
        }
    }
    
    
    func stopRunning() {
        performConfiguration { () -> Void in
            self.session.stopRunning()
        }
    }
}
    
extension ViewController: AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
        
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        //let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        //let image = CIImage(CVPixelBuffer: pixelBuffer!)
        
        //        self.delegate?.cameraController?(self, didOutputImage: image)
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        /*
        var faces = Array<(id:Int,frame:CGRect)>()
        
        for metadataObject in metadataObjects as [AVMetadataObject] {
            if metadataObject.type == AVMetadataObjectTypeFace {
                if let faceObject = metadataObject as? AVMetadataFaceObject {
                    var transformedMetadataObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject)
                    let face:(id: Int, frame: CGRect) = (faceObject.faceID, transformedMetadataObject.bounds)
                    faces.append(face)
                }
            }
        }
        
        if let delegate = self.delegate {
            dispatch_async(dispatch_get_main_queue()) {
                delegate.cameraController(self, didDetectFaces: faces)
            }
        }*/
    }
}
