//
//  ChatWindowViewController.swift
//  MessageApp
//
//  Created by Bindu Maharudrappa on 28.09.19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChatWindowViewController: UIViewController {
    
    var messages: [Message] = []
    var member: Member!
    private var chatContainerView: ORAPDFTextFieldCell?
    var isKeyboardShown : Bool = false
    var ChatWindowtitle = String()
    var timeStampString = String()
    
    @IBOutlet weak var chatingTextView: UITextView!
    @IBOutlet weak var chattableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.ChatWindowtitle
        chattableView.rowHeight = UITableView.automaticDimension
        chattableView.estimatedRowHeight = UITableView.automaticDimension
        chattableView.register(UINib(nibName: "SendMessageTableViewCell", bundle: .main), forCellReuseIdentifier: "SendMessageTableViewCell")
        chattableView.register(UINib(nibName: "RecieveTableViewCell", bundle: .main), forCellReuseIdentifier: "RecieveTableViewCell")
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            
            if self?.isKeyboardShown == true || self?.chatContainerView == nil {
                return
            }
            self?.isKeyboardShown = true
        }
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            if self?.isKeyboardShown == false || self?.chatContainerView == nil {
                return
            }
            self?.isKeyboardShown = false
            self?.chatContainerView?.chatTextView.resignFirstResponder()
        }
        self.fetchMessageData()
    }
    
    
    func fetchMessageData() {
        DispatchQueue.main.async {
            Alamofire.request("http://localhost:3000/messages").responseJSON(completionHandler: {(response) in
                switch response.result {
                case .success(let value):
                    self.messages.removeAll()
                    let json = JSON(value)
                    json.array?.forEach({(message) in
                        let message = Message(messageId: message["id"].stringValue, sender: Member(name: message["sender"].stringValue, email: "", photo: UIImage()), text: message["body"].stringValue, receiver: Member(name: message["receiver"].stringValue, email: "", photo: UIImage()), timeStamp: message["time"].stringValue)
                        self.messages.append(message)
                    })
                    self.chattableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    func postMessageData() {
        DispatchQueue.main.async {
            let urlString = "http://localhost:3000/messages"
            let parameters = ["sender": UserDefaults.standard.string(forKey: "userName")!, "body": "", "receiver": self.ChatWindowtitle, "time": ""]
            Alamofire.request(urlString, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                switch response.result {
                case .success:
                    print(response)
                    self.fetchMessageData()
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
}

extension ChatWindowViewController: UITextViewDelegate {
    // MARK: - UITextView Delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.isKeyboardShown {
            return false
        }
        if textView.inputAccessoryView == nil {
            self.chatContainerView = ORAPDFTextFieldCell.initialize()
            // Closure completion when user taps on send button in order to send the comment to the server
            self.chatContainerView?.onSendComment = { [weak self] (commentContent) in
                self?.isKeyboardShown = false
                self?.chatContainerView?.chatTextView.resignFirstResponder()
                self?.timeStampString = (self?.getTimeStamp())!
                
                DispatchQueue.main.async {
                    let urlString = "http://localhost:3000/messages"
                    let parameters = ["sender": UserDefaults.standard.string(forKey: "userName")!, "body": commentContent ?? "", "receiver": self!.ChatWindowtitle, "time": self?.timeStampString]
                    Alamofire.request(urlString, method: .post, parameters: parameters as Parameters,encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                        switch response.result {
                        case .success:
                            print(response)
                            self!.fetchMessageData()
                        case .failure(let error):
                            
                            print(error)
                        }
                    }
                }
            }
            textView.inputAccessoryView = self.chatContainerView
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.chatContainerView?.chatTextView.canResignFirstResponder == true {
            self.chatContainerView?.chatTextView.becomeFirstResponder()
        }
        
        if textView.canResignFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    func getTimeStamp() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: now)
    }
}
extension ChatWindowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserDefaults.standard.string(forKey: "userName") == self.messages[indexPath.row].sender.name {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SendMessageTableViewCell") as? SendMessageTableViewCell else {
                return UITableViewCell()
            }
            
            if UserDefaults.standard.string(forKey: "userName") == self.messages[indexPath.row].sender.name && (self.ChatWindowtitle == self.messages[indexPath.row].receiver.name){
                cell.chatTextLabel.text = messages[indexPath.row].text
                cell.dateLabel.text = messages[indexPath.row].timeStamp
                return cell
            }
            return UITableViewCell()
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecieveTableViewCell") as? RecieveTableViewCell else
            {
                return UITableViewCell()
            }
            if (self.ChatWindowtitle == self.messages[indexPath.row].sender.name) && (UserDefaults.standard.string(forKey: "userName") == self.messages[indexPath.row].receiver.name) {
                cell.chatTextLabel.text = messages[indexPath.row].text
                cell.dateLAbel.text = messages[indexPath.row].timeStamp
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

