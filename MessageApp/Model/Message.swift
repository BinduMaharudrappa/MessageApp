//
//  Message.swift
//  MessageApp
//
//  Created by Bindu Maharudrappa on 28.09.19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import Foundation
import UIKit

struct Member {
    var name: String?
    var email: String?
    var photo: UIImage?
}

struct Message {
    let messageId: String?
    var sender: Member
    var text: String?
    var receiver: Member
    var timeStamp: String?
}
