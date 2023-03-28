//
//  Post.swift
//  BeReal.
//
//  Created by Raunaq Malhotra on 3/27/23.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    
    // Required by ParseObject
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    // Custom properties for this app
    var caption: String?
    var user: User?
    var imageFile: ParseFile?
    var location: String?
}

