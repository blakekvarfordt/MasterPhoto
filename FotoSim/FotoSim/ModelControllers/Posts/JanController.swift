//
//  JanController.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

class JanController {
    
    static let shared = JanController()
    
    var posts = [JanuaryPost]()
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    
    func createPost(title: String, description: String, image: UIImage, userProfileImage: UIImage, userThatPosted: String, userReference: CKRecord.Reference, completion: @escaping (Bool) -> Void) {
        
        let post = JanuaryPost(title: title, description: description, userReference: userReference, image: image, userThatPosted: userThatPosted, userProfileImage: userProfileImage)
        if post.isBlocked == [] {
            post.isBlocked.append("Default")
        }
        let postRecord = CKRecord(januaryPost: post)
        publicDatabase.save(postRecord) { (record, error) in
            
            if let error = error {
                print("Error saving a record to database in \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let record = record, let post = JanuaryPost(ckRecord: record) else { completion(false); return }
            self.posts.append(post)
            completion(true)
        }
    }
    
    func fetchPost(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: JanuaryPostConstants.recordKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error saving a record to database in \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            let posts = records.compactMap({JanuaryPost(ckRecord: $0)})
            
             var filteredPosts: [JanuaryPost] = []
            
            for post in posts {
                guard let currentUserID = UserController.shared.currentUser?.recordID.recordName else { return }
                if post.isBlocked.contains(currentUserID) == false {
                    filteredPosts.append(post)
                }
            }
            self.posts = filteredPosts
            completion(true)
        }
    }
}
