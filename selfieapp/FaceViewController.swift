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
        
        let opts = [CIDetectorImageOrientation : 2]
        let features = detector.features(in: image, options: opts)
        
        let ciImageSize = image.extent.size
        print("image extent:\(image.extent.size) - imageViewSize:\(imageView.bounds.size)")
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        for feature in features {
            if let face = feature as? CIFaceFeature {
                if face.hasLeftEyePosition, face.hasRightEyePosition {
                    
                    // Apply the transform to convert the coordinates
                    var faceViewBounds = face.bounds.applying(transform)
                    /*
                    // Calculate the actual position and size of the rectangle in the image view
                    let viewSize = self.imageView.bounds.size
                    let scale = min(viewSize.width / ciImageSize.width,
                                    viewSize.height / ciImageSize.height)
                    let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
                    let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
                    
                    faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                    faceViewBounds.origin.x += offsetX
                    faceViewBounds.origin.y += offsetY*/
                    
                    let blackBox = UIView(frame: faceViewBounds)
                    blackBox.backgroundColor = UIColor.red
                    self.imageView.addSubview(blackBox)
                }
            }
        }
    }
}
