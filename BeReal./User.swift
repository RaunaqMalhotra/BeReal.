//
//  User.swift
//  BeReal.
//
//  Created by Raunaq Malhotra on 3/27/23.
//

import Foundation
import ParseSwift


struct User: ParseUser {
    // required by ParseUser
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String : [String : String]?]?
    
    // required by ParseObject
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
}

extension User {
    init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
}
