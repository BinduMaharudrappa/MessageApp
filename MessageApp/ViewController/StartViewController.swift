//
//  ViewController.swift
//  MessageApp
//
//  Created by Bindu Maharudrappa on 27.09.19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StartViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var chooseNameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    private var userData: [Member] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePhoto(tapGestureRecognizer:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.fetchUserData()
    }
    
    
    @IBAction func getStartedAction(_ sender: Any) {
        if self.nameTextField.text!.isEmpty || self.userPhoto.image == nil {
            
        }
        else if self.userData.contains(where: {$0.name == self.nameTextField.text}) {
            let alert = UIAlertController(title: "Alert", message: "User name already exsits, please choose different", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style {
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
   
                }}))
            self.present(alert, animated: true, completion: nil)
            return
            
        } else {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "contactListVC") as? ContactListViewController
            UserDefaults.standard.set(self.nameTextField.text, forKey: "userName")
            let image: UIImage = self.userPhoto.image!
            let imageData: NSData = image.pngData()! as NSData
            
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            UserDefaults.standard.set(strBase64, forKey: "userPhoto")
            self.postUserRequest()
            self.navigationController?.pushViewController(vc!, animated: true)
        }

    }
    
    func postUserRequest() {
        DispatchQueue.main.async {
            let urlString = "http://localhost:3000/users"
            let parameters = ["name": UserDefaults.standard.string(forKey: "userName")!, "email": "", "image": UserDefaults.standard.string(forKey: "userPhoto")]
            Alamofire.request(urlString, method: .post, parameters: parameters as Parameters,encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                switch response.result {
                case .success:
                    print(response)
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
    
    func fetchUserData() {
        DispatchQueue.main.async {
            Alamofire.request("http://localhost:3000/users").responseJSON(completionHandler: {(response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    json.array?.forEach({(user) in
                        let member = Member(name: user["name"].stringValue, email: user["email"].stringValue, photo: UIImage(named: user["image"].stringValue))
                            self.userData.append(member)
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    @objc func choosePhoto(tapGestureRecognizer: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else {
            NSLog("No Camera")
        }
    }

}

extension StartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.userPhoto.image = chosenImage
    }
}
