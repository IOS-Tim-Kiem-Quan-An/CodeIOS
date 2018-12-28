//
//  LoginViewController+handle.swift
//  GiaoDien
//
//  Created by TrucRocket on 12/22/18.
//  Copyright © 2018 Cuong. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @objc func handleLoginView() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let home2 = sb.instantiateViewController(withIdentifier: "Login") as! ViewController
        
        self.navigationController?.pushViewController(home2, animated: true)
    }
    
    
    @objc func handleRegister() {
        guard let email = emailTextField.text , let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not Value")
            return
        }
        if password != passAgainwordTextField.text
        {
            let alert =  UIAlertController(title: "Lỗi rồi", message: "Mật Khẩu của bạn không trùng nhau ", preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "ok", style: .default, handler: { (action) -> Void in
                print("ok")
                
            })
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (users, error) in
            let user = Auth.auth().currentUser
            if error != nil
            {
                print(error as Any)
                return
            }
            //successful authent users
            guard let uid = user?.uid else {
                return
            }
            
    
            let ImageName = UUID().uuidString
            
            let StorageRef = Storage.storage().reference().child("profileImg").child("\(ImageName).png")
            
            if let uploadData = self.profileImageView.image!.pngData(){
                StorageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    
                    StorageRef.downloadURL { (url, error) in
                        if let downloadURL = url?.absoluteString {
                            let value = ["name": name, "email": email,"profileImage": downloadURL] as [String : Any]
                            
                            self.RegisterUserIntoDatabaseWithUID(uid: uid, value: value as [String : AnyObject])
                            
                            
                        } else {
                            
                            return
                        }
                    }
                    
                    
                })
            }
           
        }//end authent
        
        
    }//end func
    
    
    func RegisterUserIntoDatabaseWithUID(uid: String , value: [String: AnyObject ]) {
        //thanh cong tai khoan
        var ref: DatabaseReference!
        ref = Database.database().reference(fromURL: "https://giaodiendoan.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        
        usersReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
            
            if err != nil
            {
                print(err as Any)
                return
            }
            //print(" saver user successfull info Firebase ")
            //them vao mongo
            
            
            let url = URL(string: "http://localhost:3000/addUsers")
            var req = URLRequest(url: url!)
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            req.httpMethod = "POST"
            req.httpBody = "adduid=\(uid)".data(using: .utf8)
            
            URLSession.shared.dataTask(with: req, completionHandler: { (data, res, err) in
                print(String(data: data!, encoding: .utf8)!)
            }).resume()
            
            
            //
            self.perform(#selector(self.handleLoginView), with: nil, afterDelay: 0)
        })
        
        
        
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        
        present(picker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chooseIamge: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.profileImageView.image = chooseIamge
        picker.dismiss(animated: true, completion: nil)
        
        //print(info)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("canceled piker")
    }
}



