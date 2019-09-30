//
//  MayPost.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

struct MayPostConstants {
    static let recordKey = "MayPost"
    static let titleKey = "Title"
    static let descriptionKey = "Description"
    static let timestampKey = "Timestamp"
    static let imageKey = "Image"
    static let userReferenceKey = "UserReference"
    static let userThatPostedKey = "UserThatPosted"
    static let userProfileImageKey = "UserProfileImage"
    static let isBlockedKey = "isBlocked"
}

class MayPost {
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
        guard let title = ckRecord[MayPostConstants.titleKey] as? String,
            let description = ckRecord[MayPostConstants.descriptionKey] as? String,
            let timestamp = ckRecord[MayPostConstants.timestampKey] as? Date,
            let userReference = ckRecord[MayPostConstants.userReferenceKey] as? CKRecord.Reference,
            let imageAsset = ckRecord[MayPostConstants.imageKey] as? CKAsset,
            let userThatPosted = ckRecord[MayPostConstants.userThatPostedKey] as? String,
            let userProfileImageAsset = ckRecord[MayPostConstants.userProfileImageKey] as? CKAsset else { return nil }
        
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.userReference = userReference
        self.userThatPosted = userThatPosted
        self.recordID = ckRecord.recordID
        if let isBlocked = ckRecord[MayPostConstants.isBlockedKey] as? [String] {
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
    convenience init(mayPost: MayPost) {
        self.init(recordType: MayPostConstants.recordKey, recordID: mayPost.recordID)
        self.setValue(mayPost.title, forKey: MayPostConstants.titleKey)
        self.setValue(mayPost.description, forKey: MayPostConstants.descriptionKey)
        self.setValue(mayPost.timestamp, forKey: MayPostConstants.timestampKey)
        self.setValue(mayPost.imageAsset, forKey: MayPostConstants.imageKey)
        self.setValue(mayPost.userProfileImageAsset, forKey: MayPostConstants.userProfileImageKey)
        self.setValue(mayPost.userReference, forKey: MayPostConstants.userReferenceKey)
        self.setValue(mayPost.userThatPosted, forKey: MayPostConstants.userThatPostedKey)
        
        if !mayPost.isBlocked.isEmpty {
            self.setValue(mayPost.isBlocked, forKey: MayPostConstants.isBlockedKey)
        }
    }
}

