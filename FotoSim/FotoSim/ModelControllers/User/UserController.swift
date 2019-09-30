//
//  UserController.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

class UserController {
    
    
    static let shared = UserController()
    
    var currentUser: User?
    
    var otherUser: User?
    
    var userReference: CKRecord.Reference?
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    func createUser(username: String, email: String, profileImage: UIImage, completion: @escaping (Bool) -> Void) {
            CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            if let error = error {
                print("Error saving a record to database in \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let recordID = recordID else { completion(false); return }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            let newUser = User(username: username, email: email, appleUserReference: reference, profileImage: profileImage)
            self.userReference = reference
            let userRecord = CKRecord(user: newUser)
            self.publicDatabase.save(userRecord, completionHandler: { (record, error) in
                
                if let error = error {
                    print("Error saving a record to database in \(#function) \(error) \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let record = record {
                    let savedUser = User(ckRecord: record)
                    self.currentUser = savedUser
                    completion(true)
                }
            })
        }
    }
    
    func fetchCurrentUserReference(completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching a referenceID to database in \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                self.userReference = reference
                completion(true)
            }
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        
        // use the commented out code below to sign in with the other user to test your apps features
        
        //        let fakeRecordID = CKRecord.ID(recordName: "otherUser")
        //        let fakeReference = CKRecord.Reference(recordID: fakeRecordID, action: .deleteSelf)
        //        userReference = fakeReference
        //        print("using the fake user")
        
        guard let reference = userReference else { completion(false); return }
        let predicate = NSPredicate(format: "\(UserConstants.appleUserReferenceKey) == %@", reference)
        let query = CKQuery(recordType: UserConstants.userRecordTypeKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (record, error) in
            
            if let error = error {
                print("Error fetching a record to database in \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let record = record?.first {
                let foundUser = User(ckRecord: record)
                self.currentUser = foundUser
                completion(true)
            }
        }
    }
}
