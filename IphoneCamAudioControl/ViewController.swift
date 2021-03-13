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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initializeCaptureSession()
        
    }
    
    @IBAction func zoomInOrOut(){
        
        var i = 1.0
        
        while i < 16.0 {
            
            do{
                
                // Based on the stuff about the session Q
                // This should be a mutex block
                try camera!.lockForConfiguration()
                
                // Uses the AVCaptureDevice and zooms in
//                 print(camera!.maxAvailableVideoZoomFactor) // 16.0
//                 print(camera!.minAvailableVideoZoomFactor) // 1.0
                
                // The rate used in this case is 1, IDK the range of values, but I tried 50 and it was too fast. 5 is a steady zoom, alike to canon camera
                camera!.ramp(toVideoZoomFactor: CGFloat(i),
                            withRate: 1)
                
                // Unlock mutex lock here, crucial else the program may not function well
                camera!.unlockForConfiguration()
                
                // For Debugging
                print(" IN ZOOM ")
                
                sleep(1)
            }catch{
                print(error.localizedDescription)
            }
            i += 0.5
        }
        
        
        
    }
    
    
    func displayCapturedPhoto(capturedPhoto : UIImage) {
        
        // Notice the user of identifier here
        // We are using the storyboard identifier to create this view controller
        // This is so cool, we render the view from here!
        let imagePreviewViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        
        // Pass captured photo to it to display
        imagePreviewViewController.capturedImage = capturedPhoto
        
        // Push it to navigation controller stack which manages the navigation between the embedded views
        navigationController?.pushViewController(imagePreviewViewController, animated: true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        
        // I could just transfer code from this call into here
        // BUT since this is a callback, I would want to add is as a call so that I could add any other calls where appropriate
        takePicture()
        
    }
    
    func initializeCaptureSession() {
        
        // IDK if this works
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
        
        // This is to define our own settings
        // Which is not exactly necessary, might remove this in the future?
        // No I will use this later to add more elaborate settings in the future
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        // Add in the flash animation to signify that a picture has been taken
        
        // This is to reduce the opacity and simulate the take photo action (ie. The flash )
        captureFlash(isFlash: true)
        
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
}

// This delegate is for the function above
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
            
            // This call is deprecated, need to figure out how to do this later
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                
                // This is the captured image
                if let finalImage = UIImage(data: dataImage) {
                    
                    // We will display image
                    // later should come in and change this to save image instead
                    
                    UIImageWriteToSavedPhotosAlbum(finalImage,nil,nil,nil)
//                    displayCapturedPhoto(capturedPhoto: finalImage)
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



















