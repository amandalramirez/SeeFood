//
//  ViewController.swift
//  See Food
//
//  Created by Amanda Ramirez on 5/14/18.
//  Copyright © 2018 Amanda Ramirez. All rights reserved.
//

import UIKit
import CoreML
import Vision /*will help us process images more easily, and allows us to
             use images with CoreML without writing a lot of code*/

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBOutlet weak var imageView: UIImageView!
    
    //create new image picker object
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera // .photoLibrary for user's photo library 
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //display the selected image as the image for the imageView
            imageView.image = userPickedImage //types fixed using optional binding and down casting
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not covert image to CIImage.")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { /*we will be using this model to classify our image
                                                                            VNCoreMLModel comes from vision which uses CoreML to classify*/
        //if above try fails, then model will be nil
            fatalError("Loading CoreML model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            //print(results) <- this will print all the results of matching the image to what it is
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

