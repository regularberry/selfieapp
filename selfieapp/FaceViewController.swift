//
//  FaceViewController.swift
//  selfieapp
//
//  Created by Sean Berry on 9/28/17.
//  Copyright © 2017 Sean Berry. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var uiImage: UIImage?
    
    static func create(_ image: UIImage? = nil) -> FaceViewController {
        let story = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = story.instantiateViewController(withIdentifier: "faceVC") as! FaceViewController
        vc.uiImage = image
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let i = uiImage else {
            return
        }
        self.imageView.image = i
        self.detectEyes(image: CIImage(image: i)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func detectEyes(image: CIImage) {
        let detectorObj = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        guard let detector = detectorObj else {
            return
        }
        print("image extent:\(image.extent.size) - imageViewSize:\(imageView.bounds.size)")
        let opts = [CIDetectorImageOrientation : 6]
        let features = detector.features(in: image, options: opts)
        
        for feature in features {
            if let face = feature as? CIFaceFeature {
                if face.hasLeftEyePosition, face.hasRightEyePosition {
                    let width = 140
                    let height = 60
                    var leftEyeBounds = CGRect(x: 0, y: 0, width: width, height: height)
                    leftEyeBounds = leftEyeBounds.setCenter(face.leftEyePosition)
                    
                    let redBox = UIView(frame: translateRect(leftEyeBounds, image: image))
                    redBox.backgroundColor = UIColor.red
                    self.imageView.addSubview(redBox)
                    
                    var rightEyeBounds = CGRect(x: 0, y: 0, width: width, height: height)
                    rightEyeBounds = rightEyeBounds.setCenter(face.rightEyePosition)
                    
                    let blueBox = UIView(frame: translateRect(rightEyeBounds, image: image))
                    blueBox.backgroundColor = UIColor.blue
                    self.imageView.addSubview(blueBox)
                }
            }
        }
    }
    
    func translateRect(_ rect: CGRect, image: CIImage) -> CGRect {
        let ciImageSize = image.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        var finalRect = rect.applying(transform)
        
        // Calculate the actual position and size of the rectangle in the image view
        let viewSize = self.imageView.bounds.size
        let scale = min(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height)
        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
        
        finalRect = finalRect.applying(CGAffineTransform(scaleX: scale, y: scale))
        finalRect.origin.x += offsetX
        finalRect.origin.y += offsetY
        return finalRect
    }
}

extension CGRect {
    func setCenter(_ center: CGPoint) -> CGRect {
        return CGRect(x: center.x - size.width/2, y: center.y + size.height/2, width: size.width, height: size.height)
    }
}
