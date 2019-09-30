//
//  MarchPost.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

struct MarchPostConstants {
    static let recordKey = "MarchPost"
    static let titleKey = "Title"
    static let descriptionKey = "Description"
    static let timestampKey = "Timestamp"
    static let imageKey = "Image"
    static let userReferenceKey = "UserReference"
    static let userThatPostedKey = "UserThatPosted"
    static let userProfileImageKey = "UserProfileImage"
    static let isBlockedKey = "isBlocked"
}

class MarchPost {
    let title: String
    let description: String
    let timestamp: Date
    let userThatPosted: String?
    let recordID: CKRecord.ID
    let userReference: CKRecord.Reference?
    var isBlocked: [String] = []
    var imageData: Data?
    var image: UIImage? {
        get {
            guard let imageData = imageData else { return nil }
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
    
    var userProfileImageData: Data?
    var userProfileImage: UIImage? {
        get {
            guard let imageData = userProfileImageData else { return nil }
            return UIImage(data: imageData)
        } set {
            userProfileImageData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var userProfileImageAsset: CKAsset? {
        let tempDictionary = NSTemporaryDirectory()
        let tempDictionaryURL = URL(fileURLWithPath: tempDictionary)
        let userProfileImageFileURL = tempDictionaryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpgs")
        do {
            try userProfileImageData?.write(to: userProfileImageFileURL)
        } catch {
            print("Error writing to temp URL \(error) \(error.localizedDescription)")
        }
        return CKAsset(fileURL: userProfileImageFileURL)
    }
    
    init(title: String, description: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference, image: UIImage, userThatPosted: String, userProfileImage: UIImage) {
        
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.recordID = recordID
        self.userReference = userReference
        self.userThatPosted = userThatPosted
        self.userProfileImage = userProfileImage
        self.image = image
    }
    
    init?(ckRecord: CKRecord) {
        guard let title = ckRecord[MarchPostConstants.titleKey] as? String,
            let description = ckRecord[MarchPostConstants.descriptionKey] as? String,
            let timestamp = ckRecord[MarchPostConstants.timestampKey] as? Date,
            let userReference = ckRecord[MarchPostConstants.userReferenceKey] as? CKRecord.Reference,
            let imageAsset = ckRecord[MarchPostConstants.imageKey] as? CKAsset,
            let userThatPosted = ckRecord[MarchPostConstants.userThatPostedKey] as? String,
            let userProfileImageAsset = ckRecord[MarchPostConstants.userProfileImageKey] as? CKAsset else { return nil }
        
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.userReference = userReference
        self.userThatPosted = userThatPosted
        self.recordID = ckRecord.recordID
        if let isBlocked = ckRecord[MarchPostConstants.isBlockedKey] as? [String] {
            self.isBlocked = isBlocked
        }
        
        
        guard let url = imageAsset.fileURL else { return }
        
        do {
            self.imageData = try Data(contentsOf: url)
        } catch {
            print("Error converting imageAsset to Data \(error) \(error.localizedDescription)")
        }
        
        guard let profileImageURL = userProfileImageAsset.fileURL else { return }
        
        do {
            self.userProfileImageData = try Data(contentsOf: profileImageURL)
        } catch {
            print("Error converting imageAsset to Data \(error) \(error.localizedDescription)")
        }
        
    }
}

extension CKRecord {
    convenience init(marchPost: MarchPost) {
        self.init(recordType: MarchPostConstants.recordKey, recordID: marchPost.recordID)
        self.setValue(marchPost.title, forKey: MarchPostConstants.titleKey)
        self.setValue(marchPost.description, forKey: MarchPostConstants.descriptionKey)
        self.setValue(marchPost.timestamp, forKey: MarchPostConstants.timestampKey)
        self.setValue(marchPost.imageAsset, forKey: MarchPostConstants.imageKey)
        self.setValue(marchPost.userProfileImageAsset, forKey: MarchPostConstants.userProfileImageKey)
        self.setValue(marchPost.userReference, forKey: MarchPostConstants.userReferenceKey)
        self.setValue(marchPost.userThatPosted, forKey: MarchPostConstants.userThatPostedKey)
        
        if !marchPost.isBlocked.isEmpty {
            self.setValue(marchPost.isBlocked, forKey: MarchPostConstants.isBlockedKey)
        }
    }
}
