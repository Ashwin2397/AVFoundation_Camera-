//
//  ViewController.swift
//  IphoneCamAudioControl
//
//  Created by James on 2021-03-11.
//

import Foundation
import UIKit
import AVFoundation

class ViewController : UIViewController {
    

    let session = AVCaptureSession() // To allow for camera's "session"
    var camera : AVCaptureDevice?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
    
    @IBOutlet weak var zoomTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initializeCaptureSession()
        
    }
    
    
    @IBAction func zoomButton(){
        
        let zoomFactor = (zoomTextField.text! as NSString).floatValue
        
        // This handles the zoom functionality
        // I could just transfer code from this call into here
        // BUT since this is a callback, I would want to add it as a call so that I could add any other calls where appropriate
        zoomInOrOut(zoomFactor: zoomFactor)
        
       
        
    }
    
    @IBAction func shootButton(_ sender: Any){
        
        // This call is here due to same reason provided in zoomButton()
        takePicture()
        
    }
    
    func zoomInOrOut(zoomFactor: Float){
    /*
    * This function zooms in as per the provided zoom factor
    * @param: zoomFactor The zoom factor *must* be provided as a float
    */
        do{
            
            // Based on the stuff about the session Q
            // This should be a mutex block
            try camera!.lockForConfiguration()
            
            // Uses the AVCaptureDevice and zooms in
            // print(camera!.maxAvailableVideoZoomFactor) // 16.0
            // print(camera!.minAvailableVideoZoomFactor) // 1.0
            
            
            // The rate used in this case is 1, IDK the range of values, but I tried 50 and it was too fast. '1' is a steady zoom, alike to canon camera
            camera!.ramp(toVideoZoomFactor: CGFloat(zoomFactor), withRate: 1)
            
            // Unlock mutex lock here, crucial else the program may not function well
            camera!.unlockForConfiguration()
            
        }catch{
            print(error.localizedDescription)
        }

        
    }
    func initializeCaptureSession() {
    /*
    * This function initializes the capture session by:
    * 1. Initialize camera as the input
    * 2. Initialize output to deal with captures
    * 3. Add both input and output to the session
    * 4. Initalize the camera's preview layer (Can be refactored to another function?)
    * 5. Finally starts the session
    */
        // For high resolution images
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Select capture device
        camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            
            // Initialize camera as the input device
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            
            // This is how we handle the output from a capture
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            // Add camera input and output to this session
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            
        } catch {
            print(error.localizedDescription)
        }
        
        // This displays a live video feed from the camera whenever the session is running.
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        // Defines how the layer displays the stream with respect to its bounds
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // Defines the bounds of the frame
        cameraPreviewLayer?.frame = view.bounds
        
        // Defines orientation of the preview
        // Will toggle this later
        cameraPreviewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
        
        // This targets the current view and inserts the camera preview layer at the z index of 0
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        // This allows data to flow from inputs to outputs
        session.startRunning()
    }
    
    func takePicture() {
    /*
    * This function is called by the callback to capture the image.
    */
        // This is to define our own settings
        // Not necessary, but I will leave this here to remind myself of this object and maybe use it in the future?
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        // Add in the flash animation to signify that a picture has been taken
        captureFlash(isFlash: true)
        
        // This call actually takes the picture
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
}

// This delegate is for the function above
// Apparently it is best practise to use "extension" in the case for adding delegate roles to this class
// It makes perfect sense to do this though, might want to keep this in mind 
// Other than that, it is virtually the same as including these calls in the class
extension ViewController : AVCapturePhotoCaptureDelegate {
    
    // This is to handle the captured images
    // We have to implement this function to implement the AVCapturePhotoCaptureDelegate interface
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        // Log error if any
        if let unwrappedError = error {
            print(unwrappedError.localizedDescription)
        } else {
            
            // This is to increase the opacity back to 1 and simulate the flash
            captureFlash(isFlash: false)
            
            // This call is deprecated, need to figure out another way later. However it works perfectly fine
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                
                // This is the captured image
                if let finalImage = UIImage(data: dataImage) {
                    
                    // This then saves the image to the local library
                    // The other parameters are for issuing "Saved" notification to user etc.
                    // It is elaborated in my notes
                    UIImageWriteToSavedPhotosAlbum(finalImage,nil,nil,nil)

                }
            }
        }
    }
    
    func captureFlash(isFlash: Bool){
    /*
    * This toggles the opacity to simulate the flash
    * @param: isFlash Pass in true for "switching on" the animation and false for "switching off" the animation
    */
        if( isFlash ){
            view.alpha = 0.5
        }else{
            view.alpha = 1
        }
        
    }
}



















