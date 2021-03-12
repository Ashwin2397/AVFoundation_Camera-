//
//  ImagePreviewController.swift
//  IphoneCamAudioControl
//
//  Created by James on 2021-03-11.
//

import Foundation
import UIKit

class ImagePreviewViewController : UIViewController {
    
    // This just displays the captured image almost like an overlay
    var capturedImage : UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = capturedImage
    }
    
    // This is where the image gets saved upon the button press
    @IBAction func saveImage(_ sender: Any) {
        
        print("Save image here")
        
        // This line allows us to save photos to the users gallery 
        UIImageWriteToSavedPhotosAlbum(capturedImage!,nil,nil,nil)
            
    }
    
}
