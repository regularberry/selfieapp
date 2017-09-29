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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let i = imageView.image else {
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
                    
                    let redBox = UIView(frame: rectFromEyePos(face.leftEyePosition, imageSize: image.extent.size))
                    redBox.backgroundColor = UIColor.black
                    self.imageView.addSubview(redBox)
                    
                    let blueBox = UIView(frame: rectFromEyePos(face.rightEyePosition, imageSize: image.extent.size))
                    blueBox.backgroundColor = UIColor.black
                    self.imageView.addSubview(blueBox)
                }
            }
        }
    }
    
    func rectFromEyePos(_ point: CGPoint, imageSize: CGSize) -> CGRect {
        let viewSize = self.imageView.bounds.size
        let scale = min(viewSize.width / imageSize.height,
                        viewSize.height / imageSize.width)
        let offsetX = (viewSize.width - imageSize.height * scale) / 2
        let offsetY = (viewSize.height - imageSize.width * scale) / 2
        
        let yPosPerc = point.x / imageSize.width
        var yPos = offsetY + yPosPerc * imageSize.width * scale
        
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
