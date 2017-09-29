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
    @IBOutlet weak var imageView: UIImageView!
    private var sessionQueue = DispatchQueue(label: "com.example.session_access_queue")
    
    private var session:AVCaptureSession!
    private var cameraDevice:AVCaptureDevice?
    private var stillCameraOutput:AVCaptureStillImageOutput!
    private var videoOutput:AVCaptureVideoDataOutput!
    private var metadataOutput:AVCaptureMetadataOutput!
    
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
    
    func performConfiguration(block: @escaping (() -> Void)) {
        sessionQueue.async() { () -> Void in
            block()
        }
    }
    
    func performConfigurationOnCurrentCameraDevice(block: @escaping ((_ currentDevice:AVCaptureDevice) -> Void)) {
        if let device = self.cameraDevice {
            performConfiguration { () -> Void in
                do {
                    try device.lockForConfiguration()
                    block(device)
                    device.unlockForConfiguration()
                } catch {
                    
                }
            }
        }
    }

    func hideSensitiveData() {
        takeScreenshot(self)
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

extension UIImage
{
    // Translated from <https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW4>
    convenience init?(fromSampleBuffer sampleBuffer: CMSampleBuffer)
    {
        guard let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        if CVPixelBufferLockBaseAddress(imageBuffer, .readOnly) != kCVReturnSuccess { return nil }
        defer { CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly) }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(imageBuffer),
            width: CVPixelBufferGetWidth(imageBuffer),
            height: CVPixelBufferGetHeight(imageBuffer),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(imageBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let c = context, let quartzImage = c.makeImage() else { return nil }
        self.init(cgImage: quartzImage)
    }
}
