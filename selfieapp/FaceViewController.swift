//
//  FaceViewController.swift
//  selfieapp
//
//  Created by Sean Berry on 9/28/17.
//  Copyright © 2017 Sean Berry. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController, DisplaysSensitiveData {

    @IBOutlet weak var imageView: UIImageView!
    var uiImage: UIImage?
    var blackBoxes: [UIView] = []
    
    static func create(_ image: UIImage? = nil) -> FaceViewController {
        let story = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = story.instantiateViewController(withIdentifier: "faceVC") as! FaceViewController
        vc.uiImage = image
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let i = uiImage else {
            return
        }
        self.imageView.image = i
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideSensitiveData() {
        guard let i = uiImage, let ciImage = CIImage(image: i) else {
            return
        }
        hideEyes(image: ciImage)
    }
    
    func showSensitiveData() {
        for box in blackBoxes {
            box.removeFromSuperview()
        }
        blackBoxes = []
    }

    func hideEyes(image: CIImage) {
        let detectorOptions = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        
        guard let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions) else {
            return
        }
        
        let features = detector.features(in: image, options: [CIDetectorImageOrientation : 6])
        let imageSize = image.extent.size
        
        for feature in features {
            if let face = feature as? CIFaceFeature {
                if face.hasLeftEyePosition {
                    makeBox(face.leftEyePosition, imageSize: imageSize)
                }
                
                if face.hasRightEyePosition {
                    makeBox(face.rightEyePosition, imageSize: imageSize)
                }
            }
        }
    }
    
    func makeBox(_ point: CGPoint, imageSize: CGSize) {
        let box = UIView(frame: rectFromEyePos(point, imageSize: imageSize))
        box.backgroundColor = UIColor.black
        blackBoxes.append(box)
        self.imageView.addSubview(box)
    }
    
    func rectFromEyePos(_ point: CGPoint, imageSize: CGSize) -> CGRect {
        let viewSize = self.imageView.bounds.size
        let scale = min(viewSize.width / imageSize.height,
                        viewSize.height / imageSize.width)
        let offsetX = (viewSize.width - imageSize.height * scale) / 2
        let offsetY = (viewSize.height - imageSize.width * scale) / 2
        
        let yPosPerc = point.x / imageSize.width
        let yPos = offsetY + yPosPerc * imageSize.width * scale
        
        let xPosPerc = point.y / imageSize.height
        let xPos = offsetX + xPosPerc * viewSize.width
        
        let width = 60
        let height = 20
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        bounds = bounds.setCenter(CGPoint(x: xPos, y: yPos))
        return bounds
    }
}

extension CGRect {
    func setCenter(_ center: CGPoint) -> CGRect {
        return CGRect(x: center.x - size.width/2, y: center.y - size.height/2, width: size.width, height: size.height)
    }
}
