//
//  ContactListViewController.swift
//  MessageApp
//
//  Created by Bindu Maharudrappa on 27.09.19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContactListViewController: UIViewController {

    @IBOutlet weak var contactTableView: UITableView!
    
    var userDataArray: [Member] = []
    var searchMemberArray = [Member]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Allymatches"
        self.navigationController?.navigationBar.tintColor = .white
        self.contactTableView.rowHeight = UITableView.automaticDimension
        self.contactTableView.estimatedRowHeight = UITableView.automaticDimension
        self.contactTableView.register(UINib(nibName: "ContactListTableViewCell", bundle: nil), forCellReuseIdentifier: "contactListCell")
        self.fetchUserData()
    }
    
    func fetchUserData() {
        DispatchQueue.main.async {
            Alamofire.request("http://localhost:3000/users").responseJSON(completionHandler: {(response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    json.array?.forEach({(user) in
                        let member = Member(name: user["name"].stringValue, email: user["email"].stringValue, photo: UIImage(named: user["image"].stringValue))
                        if UserDefaults.standard.string(forKey: "userName") != member.name {
                            self.userDataArray.append(member)
                        }
                    })
                    self.searchMemberArray = self.userDataArray
                    self.contactTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
}

extension ContactListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchMemberArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "contactListCell", for: indexPath) as! ContactListTableViewCell
        cell.userDisplayName.text = self.searchMemberArray[indexPath.row].name
        cell.userPhoto.image = self.searchMemberArray[indexPath.row].photo

        return cell
        
    }
}

extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "chatVC") as? ChatWindowViewController
        chatVC?.ChatWindowtitle = self.userDataArray[indexPath.row].name!
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(chatVC!, animated: true)
    }
}

extension ContactListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.searchMemberArray = self.userDataArray
            self.contactTableView.reloadData()
            return
        }
        self.searchMemberArray = self.userDataArray.filter({member -> Bool in
            return (member.name?.lowercased().contains(searchText.lowercased()))!
        })
        self.contactTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
