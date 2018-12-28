//
//  Home2ViewController.swift
//  GiaoDien
//
//  Created by Cuong on 12/3/18.
//  Copyright © 2018 Cuong. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class Home2ViewController: UIViewController,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    var checkBook:Int = 10
    @IBOutlet weak var tableviewMenu: UITableView!
    @IBOutlet weak var lblNameStore: UILabel!
    @IBOutlet weak var imgStoreView: UIImageView!
    
    
    
    @IBOutlet weak var lblContentStore: UILabel!
    var chuyenid:String!
    var chuyenurlhinh:String!
    var chuyenNameStore:String!
    var chuyenAddrStore:String!
    var chuyenContent:String!
    var chuyenvido:String!
    var chuyenkinhdo:String!
    @IBOutlet weak var mkMapview: MKMapView!
    var locationManager = CLLocationManager()
    var annotationArray:[CustomAnnotation] = [CustomAnnotation]()
    
    var myTableMenu = [NewMenu]()
    
    @objc func saveview(){
        let uid = Auth.auth().currentUser?.uid
       
        let url = URL(string: "http://localhost:3000/addSaveUser")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
//        req.httpBody = "IDStore\(chuyenid!)&Urlstore\(chuyenurlhinh!)&NameStore\(chuyenNameStore!)&AddrStore\(chuyenAddrStore!)&kinhdo\(chuyenkinhdo!)&vido\(chuyenvido!)&ConStore\(chuyenContent!)&iduser\(uid!)".data(using: .utf8)
        let postString = "IDStore=\(chuyenid!)&Urlstore=\(chuyenurlhinh!)&NameStore=\(chuyenNameStore!)&AddrStore=\(chuyenAddrStore!)&kinhdo=\(chuyenkinhdo!)&vido=\(chuyenvido!)&ConStore=\(chuyenContent!)&iduser=\(uid!)"
        req.httpBody = postString.data(using: .utf8)
//        print(postString)
        
        URLSession.shared.dataTask(with: req, completionHandler: { (data, res, err) in
            print("congratulations")
        }).resume()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đã Lưu bài viết", style: .plain, target: self, action: #selector(saveview))

    }
    override func viewWillAppear(_ animated: Bool) {
        loadMenu()
        
    }
    func checkSave(uid: String, idSave: String) -> Int {
        
        let url = URL(string: "http://localhost:3000/check")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
        req.httpBody = "uidUser=\(uid)&idSave=\(idSave)".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: req, completionHandler:{ (data, res, err) in
            print(String(data: data!, encoding: .utf8)!)
            let check = (String(data: data!, encoding: .utf8)!)
            if check == "1"{
                self.checkBook = 1
                
            }
            else{
                self.checkBook = 0
//                print(self.checkSave!)
            }
        })
        task.resume()
        print(self.checkBook)
        print("-------")
        return checkBook
    }
    @objc func Didsaveview(){
        let uid = Auth.auth().currentUser?.uid
        
        let url = URL(string: "http://localhost:3000/deleteSave")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
        
        let postString = "idStore=\(chuyenid!)&uid=\(uid!)"
        req.httpBody = postString.data(using: .utf8)
        //        print(postString)
        
        URLSession.shared.dataTask(with: req, completionHandler: { (data, res, err) in
            print("congratulations")
        }).resume()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lưu bài viết", style: .plain, target: self, action: #selector(saveview))
    }
    override func viewDidAppear(_ animated: Bool) {
        let uid = Auth.auth().currentUser?.uid
        if checkSave(uid: uid!, idSave: chuyenid!) == 0
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lưu bài viết", style: .plain, target: self, action: #selector(saveview))
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đã Lưu bài viết", style: .plain, target: self, action: #selector(Didsaveview))
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        if Auth.auth().currentUser?.uid != nil{
//            checkSave(uid: uid!, idSave: chuyenid!)
            if checkSave(uid: uid!, idSave: chuyenid!) == 0
            {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lưu bài viết", style: .plain, target: self, action: #selector(saveview))
            }
            else{
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đã Lưu bài viết", style: .plain, target: self, action: #selector(Didsaveview))
            }

        }
        
        
        
        
        //ho con rua 10.782742, 106.695907
        mkMapview.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //print(chuyenid!)
        self.addAnnotationsOnMapView()
        
        //mkview.addAnnotation(annotation)
        
        mkMapview.addAnnotations(self.annotationArray)
       
        //load imgStore
        let url:URL = URL(string: chuyenurlhinh!)!
        do
        {
            let dulieu:Data = try Data(contentsOf: url)
            imgStoreView.image = UIImage(data: dulieu)
        }
        catch
        {
            
        }
        //end load ImgStore
        lblNameStore.text = chuyenNameStore
        lblContentStore.text = chuyenContent
        
        
       
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTableMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableviewMenu.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        let myImgV = myCell.viewWithTag(10) as! UIImageView
        let myLbName = myCell.viewWithTag(11) as! UILabel
        let myLblPrice = myCell.viewWithTag(12) as! UILabel
        
        myLbName.text = myTableMenu[indexPath.row].namefood
        myLblPrice.text = myTableMenu[indexPath.row].price
        
        let myURl = myTableMenu[indexPath.row].urlimg
        loadImg(url: myURl, to: myImgV)
        
        
        return myCell
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
    

    func loadMenu() {
        var myMenu = NewMenu()
//        let url = URL(string: "http://iosfoody.club/find")
        let url = URL(string: "http://localhost:3000/find")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
        //req.setValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded")
        req.httpBody = "idfind=\(chuyenid!)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: req) { (data, response, error) in
            if error != nil
            {
                print("error herr...")
                print(error!)
            }
                
                
            else
            {
                //print(String(data: data!, encoding: .utf8)!)
                if let content = data
                {
                    do
                    {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers)
                        //print("-----------")
                        //print(myJson)
                        if let jsonData = myJson as? [String:Any]
                        {
                            if let myResult = jsonData["result"] as? [String:Any]
                            {
                                if let myMoreCont = myResult["MoreContents"] as? [[String:Any]]
                                {
                                    for value in myMoreCont
                                    {
                                        if let idFood = value["_id"] as? String
                                        {
                                            myMenu.id = idFood
                                        }
                                        if let urlFood = value["ImgFood"] as? String
                                        {
                                            //print(urlFood)
                                            myMenu.urlimg = urlFood
                                        }
                                        if let namefood = value["ImgNameFood"] as? String
                                        {
                                            myMenu.namefood = namefood
                                        }
                                        if let price = value["Price"] as? String
                                        {
                                            myMenu.price = price
                                        }
                                        self.myTableMenu.append(myMenu)
                                    }//end for loot
//                                    dump(self.myTableMenu)
                                    DispatchQueue.main.async {
                                        self.tableviewMenu.reloadData()
                                    }
                                }
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
   

    
    func addAnnotationsOnMapView(){
        // dia chi dinh vi
// --       let currentLocation = locationManager.location?.coordinate
        
// --       let sourceAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: (currentLocation?.latitude)!, longitude: (currentLocation?.longitude)!), title: "HERE", subtitle: "Vi tri cua ban")
        
    
        
// --       self.annotationArray.append(sourceAnnotation)
        //10.851201, 106.772087
        let currentLocation = CLLocationCoordinate2D(latitude: 10.851201, longitude: 106.772087)
        
        let sourceAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude), title: "It", subtitle: "Vi Tri Cua ban")
        
        
        
         self.annotationArray.append(sourceAnnotation)
        
        
        let lat = Double(chuyenvido) ?? 0.0
        let longi = Double(chuyenkinhdo) ?? 0.0
        
        let destinationLocation = CLLocationCoordinate2D(latitude: lat, longitude: longi)
        
        let destinationAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude), title: "Here", subtitle: "Diem Den")
        
        self.annotationArray.append(destinationAnnotation)
        
        
        self.DrawTwoLocaltion(sourceLocation: currentLocation, destinationLocation: destinationLocation)
        
    }
    
    func DrawTwoLocaltion(sourceLocation: CLLocationCoordinate2D,destinationLocation: CLLocationCoordinate2D)
    {
        //step 1
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        //2
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        //3
        let directRequest = MKDirections.Request()
        
        directRequest.source = sourceMapItem
        
        directRequest.destination = destinationMapItem
        //chon phuong tien di chuyen .automobile la di bang phuong tien
        directRequest.transportType = .automobile
        
        //4
        
        let direction = MKDirections(request: directRequest)
        
        direction.calculate { (response, error) in
            if error == nil
            {
                if let route = response?.routes.first{
                    self.mkMapview.addOverlay(route.polyline, level: .aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    
                    self.mkMapview.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 20, right: 20), animated: true)
                    
                }
            }else {
                print(error?.localizedDescription as Any)
            }
        }
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rederer = MKPolylineRenderer(overlay: overlay)
        rederer.strokeColor = UIColor.blue
        rederer.lineWidth = 5.0
        return rederer
    }
    func loadUser(uid: String) {
        
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
//                                    self.UserMongo.id = idu
                                    print(idu)
                                }
                                if let idFirebase = myResult["uid"] as? String{
//                                    self.UserMongo.uid = idFirebase
                                    print(idFirebase)
                                }
                                
//                                dump(self.UserMongo)
                                
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
    }//end loadUserID
    
    
    
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        let region = MKCoordinateRegion(center: (currentLocation?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mkMapview.setRegion(region, animated: true)
    }*/
}//end class

