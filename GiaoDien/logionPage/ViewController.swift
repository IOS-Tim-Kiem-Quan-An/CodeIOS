//
//  ViewController.swift
//  GiaoDien
//
//  Created by Cuong on 12/1/18.
//  Copyright © 2018 Cuong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var txtTest: UITextField!
    @IBOutlet weak var buttonEditPassView: UIButton!
    @IBOutlet weak var buttonEditInfoView: UIButton!
    var UserMongo = UserFood()
    
    @IBOutlet weak var lblEmailAccout: UILabel!
    
    @IBOutlet weak var imageProfileAccout: UIImageView!
    @IBOutlet weak var NameAccout: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtTest.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if Auth.auth().currentUser?.uid == nil{
           perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
            buttonEditInfoView.layer.cornerRadius = 20
            buttonEditPassView.layer.cornerRadius = 20
            
            imageProfileAccout.layer.cornerRadius = imageProfileAccout.frame.size.width / 2
            imageProfileAccout.clipsToBounds = true
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let userID = Auth.auth().currentUser?.uid
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let username = value?["name"] as? String
                let urlImage = value?["profileImage"] as? String
                let emailUser = value?["email"] as? String
                self.NameAccout.text = username
                self.lblEmailAccout.text = emailUser
                self.loadImg(url: urlImage!, to: self.imageProfileAccout)
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            
        }
        
    }
    //alert notification
    func ThongBao(messe:String) {
        let alert:UIAlertController = UIAlertController(title: "Thông báo", message: messe, preferredStyle: .alert)
        let btnOK:UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOK)
        present(alert, animated: true, completion: nil)
    }
    //edit Info
    @IBAction func btnEditInfo(_ sender: Any) {
        
    }
    //edit Pass
    @IBAction func btnEditPass(_ sender: Any) {
        let alert:UIAlertController = UIAlertController(title: "Đổi mật khẩu", message: "Vui Lòng Nhập Thông Tin", preferredStyle: .alert)
        alert.addTextField { (txtUser) in
            txtUser.placeholder = "🔐 Nhập mật khẩu"
            txtUser.isSecureTextEntry = true
        }
        alert.addTextField { (txtpass) in
            txtpass.placeholder = "🔐 Nhập lại mật khẩu"
            txtpass.isSecureTextEntry = true
        }
        let btnLogin:UIAlertAction = UIAlertAction(title: "OK", style: .destructive) { (btnLogin) in
            let AUser:String = alert.textFields![0].text!
            let APass:String = alert.textFields![1].text!
            if AUser != APass{
                let alert2 =  UIAlertController(title: "Lỗi rồi", message: "Mật Khẩu của bạn không trùng nhau ", preferredStyle: UIAlertController.Style.alert)
                
                let ok = UIAlertAction(title: "ok", style: .default, handler: { (action) -> Void in
                    print("ok")
                    
                })
                
                alert2.addAction(ok)
                
                self.present(alert2, animated: true, completion: nil)
                
                return
            }
            else{
                let user = Auth.auth().currentUser
                user?.updatePassword(to: AUser, completion: { (error) in
                    if error != nil
                    {
                        print(error!)
                    }
                    self.ThongBao(messe: " Đổi mật khẩu thành công")
                })
            }
            
        }
        let btnCancel:UIAlertAction = UIAlertAction(title: "Huỷ", style: .cancel) { (btnCancel) in
            
        }
        
        alert.addAction(btnLogin)
        alert.addAction(btnCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
   
    }
    func loadImg(url: String, to imageview: UIImageView) {
        let url = URL(string: url)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else
            {
                return
            }
            DispatchQueue.main.async {
                imageview.image = UIImage(data: data)
            }
            }.resume()
        
    }
    @objc func handleLogout(){
        
        do{
           try Auth.auth().signOut()
        }catch let logouterror {
            print(logouterror)
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let home2 = sb.instantiateViewController(withIdentifier: "LoginRegister") as! LoginController
        
        self.navigationController?.pushViewController(home2, animated: true)
//        let loginController = LoginController()
//        present(loginController , animated: true , completion: nil)
    }
   
    func AddUserID(uid: String) {
        
        //        let url = URL(string: "http://iosfoody.club/find")
        let url = URL(string: "http://localhost:3000/findUser")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
        //req.setValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded")
        req.httpBody = "uidfind=\(uid)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: req) { (data, response, error) in
            if error != nil
            {
                print("error herr...")
                print(error!)
            }
                
                
            else
            {
//                print(String(data: data!, encoding: .utf8)!)
                if let content = data
                {
                    do
                    {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers)
                        //print("-----------")
//                        print(myJson)
                        if let jsonData = myJson as? [String:Any]
                        {
                            if let myResult = jsonData["result"] as? [String:Any]
                            {
                                        if let idu = myResult["_id"] as? String
                                        {
                                            self.UserMongo.id = idu
                                            print(idu)
                                        }
                                        if let idFirebase = myResult["uid"] as? String{
                                            self.UserMongo.uid = idFirebase
                                            print(idFirebase)
                                        }
                                
                                        dump(self.UserMongo)
                                
                            }
                        }
                    }
                    catch
                    {
                        
                    }
                }
                
            }
        }
        task.resume()
    }//end loadmenu
    
    

}

