//
//  ViewController.swift
//  Plant-Recognizer
//
//  Created by Petar Iliev on 19.11.22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var camera : UIImagePickerController?

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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage]
        imageView.image = image as? UIImage
        camera?.dismiss(animated: true)
    }
    
}

