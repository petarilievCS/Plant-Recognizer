//
//  ViewController.swift
//  Plant-Recognizer
//
//  Created by Petar Iliev on 19.11.22.
//

import UIKit
import CoreML
import Vision
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var camera : UIImagePickerController?
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = UIImagePickerController()
        camera?.delegate = self
        camera?.sourceType = .camera
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // customize navigation bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor.systemGreen
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
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
        let ExtractString = "\(wikipediaURl)?format=json&action=query&prop=extracts&exsentences=3&exintro=&explaintext=&titles=\(flowerID)&indexpageids&redirects=1"
        let ImageString = "\(wikipediaURl)?format=json&action=query&prop=pageimages&exsentences=3&exintro=&explaintext=&titles=\(flowerID)&indexpageids&redirects=1&pithumbsize=500"
        
        fetchData(with: ExtractString, for: "text")
        fetchData(with: ImageString, for: "image")
        
    }
    
    func fetchData(with URLString: String, for purpose: String) {
        if let URL = URL(string: URLString) {
            let session = URLSession(configuration: .default)
            let request = URLRequest(url: URL)
            let task = session.dataTask(with: request) { data, response, error in
                if let safeData = data {
                    if purpose == "text" {
                        if let flowerData = self.parseJSON(safeData) as? FlowerData {
                            let pageID = flowerData.query.pageids[0]
                            DispatchQueue.main.async {
                                self.textLabel.text = flowerData.query.pages[pageID]!.extract
                            }
                        }
                    } else {
                        if let imageData = self.parseJSONImage(safeData) as? ImageData {
                            let pageID = imageData.query.pageids[0]
                            let imageURL = imageData.query.pages[pageID]?.thumbnail.source
                            DispatchQueue.main.async {
                                self.imageView.sd_setImage(with: Foundation.URL(string: imageURL!))
                            }
                        }
                    }
                    
                }
            }
            task.resume()
        } else {
            fatalError("Couldn't form URL")
        }
    }
    
    // parse JSON file for image from Wikipedia
    func parseJSONImage(_ data: Data) -> Codable? {
        let decoder = JSONDecoder()
        do {
            let imageData = try decoder.decode(ImageData.self, from: data)
            return imageData
        } catch {
            print("Error while decoding data: \(error.localizedDescription)")
        }
        return nil
    }
    
    // parse JSON file from Wikipedia API
    func parseJSON(_ data: Data) -> Codable? {
        let decoder = JSONDecoder()
        do {
            let flowerData = try decoder.decode(FlowerData.self, from: data)
            return flowerData
        } catch {
            print("Error while decoding data: \(error.localizedDescription)")
        }
        return nil
    }
    
}

