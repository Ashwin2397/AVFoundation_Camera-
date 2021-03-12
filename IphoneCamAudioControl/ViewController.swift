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
        // Do any additional setup after loading the view, typically from a nib.
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
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
}

// This delegate is for the function above
extension ViewController : AVCapturePhotoCaptureDelegate {
    
    // This is to handle the captured images
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        // Log error if any
        if let unwrappedError = error {
            print(unwrappedError.localizedDescription)
        } else {
            
            // This call is deprecated, need to figure out how to do this later
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                
                // This is the captured image
                if let finalImage = UIImage(data: dataImage) {
                    
                    // We will display image
                    // later should come in and change this to save image instead
                    displayCapturedPhoto(capturedPhoto: finalImage)
                }
            }
        }
    }
}



















