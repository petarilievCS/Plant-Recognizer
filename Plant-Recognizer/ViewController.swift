//
//  ViewController.swift
//  Plant-Recognizer
//
//  Created by Petar Iliev on 19.11.22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var camera : UIImagePickerController?
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = UIImagePickerController()
        camera?.delegate = self
        camera?.sourceType = .camera
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        guard let safeCamera = camera else {
            fatalError("Camera picker not initialized")
        }
        present(safeCamera, animated: true)
    }
    
    // image taken
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            guard let coreImage = CIImage(image: image) else {
                fatalError("Failed to convert image to core image")
            }
            detect(coreImage)
        }
        
        camera?.dismiss(animated: true)
    }
    
    // classify image
    func detect(_ image: CIImage) {
        
        // create model
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Couldn't initialize CoreML model")
        }
        
        // create request
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error while accessing results")
            }
            if let firstResult = results.first {
                DispatchQueue.main.async {
                    self.navigationItem.title = firstResult.identifier
                }
                self.performGetRequest(with: firstResult.identifier)
            }
        }
        
        // perform request, update UI
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error while performing request")
        }
    }
    
    // perform GET HTTP request to Wikipedia API
    func performGetRequest(with flowerName: String) {
        
        let flowerID = flowerName.replacingOccurrences(of: " ", with: "%20")
        let URLString = "\(wikipediaURl)?format=json&action=query&prop=extracts&exintro=&explaintest=&titles=\(flowerID)&indexpageids&redirects=1"
        
        if let URL = URL(string: URLString) {
            let session = URLSession(configuration: .default)
            let request = URLRequest(url: URL)
            let task = session.dataTask(with: request) { data, response, error in
                if let safeData = data {
                    print(String(data: safeData, encoding: .utf8))
                }
            }
            task.resume()
        } else {
            fatalError("Couldn't form URL")
        }
    }
    
}

