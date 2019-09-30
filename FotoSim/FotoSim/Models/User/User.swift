//
//  User.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

struct UserConstants {
    static let userRecordTypeKey = "User"
    static let usernameKey = "Username"
    static let emailKey = "Email"
    static let imageKey = "ProfileImage"
    static let appleUserReferenceKey = "AppleUserReference"
    
}

class User {
    let username: String
    let email: String
    let recordID: CKRecord.ID
    let appleUserReference: CKRecord.Reference
    var imageData: Data?
    var profileImage: UIImage? {
        get {
            guard let imageData = imageData else { return nil}
            return UIImage(data: imageData)
        } set {
            imageData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset? {
        let tempDict = NSTemporaryDirectory()
        let tempDictURL = URL(fileURLWithPath: tempDict)
        let fileURL = tempDictURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        do {
            try imageData?.write(to: fileURL)
        } catch {
            print("Error writing to temp URL \(error) \(error.localizedDescription)")
        }
        return CKAsset(fileURL: fileURL)
    }
    
    init(username: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference, profileImage: UIImage?) {
        self.username = username
        self.email = email
        self.recordID = recordID
        self.appleUserReference = appleUserReference
        self.profileImage = profileImage
    }
    
    init?(ckRecord: CKRecord) {
        guard let username = ckRecord[UserConstants.usernameKey] as? String,
            let email = ckRecord[UserConstants.emailKey] as? String,
            let imageAsset = ckRecord[UserConstants.imageKey] as? CKAsset,
            let appleUserReference = ckRecord[UserConstants.appleUserReferenceKey] as? CKRecord.Reference else { return nil }
        
        self.username = username
        self.email = email
        self.recordID = ckRecord.recordID
        self.appleUserReference = appleUserReference
        
        guard let url = imageAsset.fileURL else { return }
        
        do {
            self.imageData = try Data(contentsOf: url)
        } catch {
            print("Error converting imageAsset to Data \(error) \(error.localizedDescription)")
        }
    }
}

extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserConstants.userRecordTypeKey, recordID: user.recordID)
        self.setValue(user.username, forKey: UserConstants.usernameKey)
        self.setValue(user.email, forKey: UserConstants.emailKey)
        self.setValue(user.imageAsset, forKey: UserConstants.imageKey)
        self.setValue(user.appleUserReference, forKey: UserConstants.appleUserReferenceKey)
    }
}
