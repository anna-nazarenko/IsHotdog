//
//  ViewController.swift
//  isHotdog
//
//  Created by Anna Nazarenko on 04.08.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func detect(image: CIImage) {
        let config = MLModelConfiguration()
        
        guard let coreModel = try? Inceptionv3(configuration: config),
              let visionModel = try? VNCoreMLModel(for: coreModel.model) else
        {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Model failed to process image.") }
            
            self.textView.text = results[0].identifier
            
            if results[0].identifier.contains("hotdog") { self.titleLabel.text = "Hotdog!" }
            else { self.titleLabel.text = "Not Hotdog!" }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
    }

    @IBAction func cameraTapped(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not convert to CIImage") }
            
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true)
    }
}
