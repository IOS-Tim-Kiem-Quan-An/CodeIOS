//
//  HomeController.swift
//  GiaoDien
//
//  Created by Cuong on 12/2/18.
//  Copyright © 2018 Cuong. All rights reserved.
//

import UIKit

enum selectedScope:Int
{
    case name = 0
    case addr = 1
}


class HomeController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var tableViewStore: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    //let url = URL(string: "http://iosfoody.club/read")
    let url = URL(string: "http://localhost:3000/read")
   
    var myTableViewDataSource = [NewInfo]()
    
    var imgQC : [String] = ["QC1","QC2","QC3"]
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewStore.dataSource = self
        tableViewStore.delegate = self
        loadlist()
        searchBarSetup()
        
        pageControl.numberOfPages = imgQC.count
        for index in 0..<imgQC.count
        {
            frame.origin.x = ScrollView.frame.size.width * CGFloat(index)
            frame.size = ScrollView.frame.size
            
            let imgViewQC = UIImageView(frame: frame)
            imgViewQC.image = UIImage(named: imgQC[index])
            self.ScrollView.addSubview(imgViewQC)
        }
        ScrollView.contentSize = CGSize(width: (ScrollView.frame.size.width * CGFloat(imgQC.count)), height: ScrollView.frame.size.height)
        ScrollView.delegate = self
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    override func viewWillAppear(_ animated: Bool) {
        //loadlist()
    }
    //search Bar
    func searchBarSetup() {
        let SearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 70))
        SearchBar.showsScopeBar = true
        SearchBar.scopeButtonTitles = ["Tên Quán","Địa Chỉ"]
        SearchBar.delegate = self
        SearchBar.selectedScopeButtonIndex = 0
        self.tableViewStore.tableHeaderView = SearchBar
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            myTableViewDataSource = [NewInfo]()
            loadlist()
            self.tableViewStore.reloadData()
        }
        else
        {
            filterTableView(ind: searchBar.selectedScopeButtonIndex, text: searchText)
        }
        //filterTableView(ind: searchBar.selectedScopeButtonIndex, text: searchText)
    }
    func filterTableView(ind:Int, text:String) {
        switch ind {
        case selectedScope.name.rawValue:
            myTableViewDataSource = myTableViewDataSource.filter( { (mod) -> Bool in
                return mod.urlName.lowercased().contains(text.lowercased())
            })
            self.tableViewStore.reloadData()
        case selectedScope.addr.rawValue:
            myTableViewDataSource = myTableViewDataSource.filter( { (mod) -> Bool in
                return mod.AddrStore.lowercased().contains(text.lowercased())
            })
            self.tableViewStore.reloadData()
        default:
            print("No type")
        }
    }
    
    //end searchBar
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let home2 = sb.instantiateViewController(withIdentifier: "Home2") as! Home2ViewController
        
        home2.chuyenid = myTableViewDataSource[indexPath.row].id
        home2.chuyenurlhinh = myTableViewDataSource[indexPath.row].urlImage
        home2.chuyenNameStore = myTableViewDataSource[indexPath.row].urlName
        home2.chuyenAddrStore = myTableViewDataSource[indexPath.row].AddrStore
        home2.chuyenContent = myTableViewDataSource[indexPath.row].content
        home2.chuyenvido = myTableViewDataSource[indexPath.row].vido
        home2.chuyenkinhdo = myTableViewDataSource[indexPath.row].kinhdo
        
        
        self.navigationController?.pushViewController(home2, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableViewStore.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let myImgView = myCell.viewWithTag(10) as! UIImageView
        let myLblName = myCell.viewWithTag(11) as! UILabel
        let myLblAddr = myCell.viewWithTag(12) as! UILabel
        let mylblContent = myCell.viewWithTag(13) as! UILabel
        
        myLblName.text = myTableViewDataSource[indexPath.row].urlName
        myLblAddr.text = myTableViewDataSource[indexPath.row].AddrStore
        mylblContent.text = myTableViewDataSource[indexPath.row].content
        
        let myURl = myTableViewDataSource[indexPath.row].urlImage
        loadImg(url: myURl, to: myImgView)
        
        return myCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
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
   
    func loadlist() {
        var myNew = NewInfo()
        
        let task = URLSession.shared.dataTask(with: url!)
        { (data, response, error) in
            if error != nil
            {
                print("err here ......")
                print(error!)
            }
            else
            {
                do
                {
                    if let conten = data
                    {
                        let myJson = try JSONSerialization.jsonObject(with: conten, options: .mutableContainers)
                        //print(myJson)
                        if let jsonData = myJson as? [String:Any]
                        {
                            if let myResult = jsonData["result"] as? [[String:Any]]
                            {
                                //dump(myResult)
                                for value in myResult
                                {
                                    if let id = value["_id"] as? String
                                    {
                                        //print(id)
                                        myNew.id = id
                                    }
                                    if let urlImg = value["urlImage"] as? String
                                    {
                                        myNew.urlImage = urlImg
                                    }
                                    if let urlName = value["ImgName"] as? String
                                    {
                                        myNew.urlName = urlName
                                    }
                                    if let addr = value["address"] as? String
                                    {
                                        myNew.AddrStore = addr
                                    }
                                    if let cont = value["contents"] as? String
                                    {
                                        myNew.content = cont
                                    }
                                    if let vido = value["vido"] as? String
                                    {
                                        myNew.vido = vido
                                    }
                                    if let kinhdo = value["kinhdo"] as? String
                                    {
                                        myNew.kinhdo = kinhdo
                                    }
                                    self.myTableViewDataSource.append(myNew)
                                }//end for ech
                                //dump(self.myTableViewDataSource)
                                DispatchQueue.main.async {
                                    self.tableViewStore.reloadData()
                                }
                            }
                            
                            
                        }
                    }
                    
                    
                }
                catch
                {
                    
                }
            }
        }//end task
        task.resume()
    }//end loadlist

}//end class

