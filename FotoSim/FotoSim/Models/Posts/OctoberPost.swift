//
//  OctoberPost.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

struct OctoberPostConstants {
    static let recordKey = "OctoberPost"
    static let titleKey = "Title"
    static let descriptionKey = "Description"
    static let timestampKey = "Timestamp"
    static let imageKey = "Image"
    static let userReferenceKey = "UserReference"
    static let userThatPostedKey = "UserThatPosted"
    static let userProfileImageKey = "UserProfileImage"
    static let isBlockedKey = "isBlocked"
}

class OctoberPost {
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
        guard let title = ckRecord[OctoberPostConstants.titleKey] as? String,
            let description = ckRecord[OctoberPostConstants.descriptionKey] as? String,
            let timestamp = ckRecord[OctoberPostConstants.timestampKey] as? Date,
            let userReference = ckRecord[OctoberPostConstants.userReferenceKey] as? CKRecord.Reference,
            let imageAsset = ckRecord[OctoberPostConstants.imageKey] as? CKAsset,
            let userThatPosted = ckRecord[OctoberPostConstants.userThatPostedKey] as? String,
            let userProfileImageAsset = ckRecord[OctoberPostConstants.userProfileImageKey] as? CKAsset else { return nil }
        
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.userReference = userReference
        self.userThatPosted = userThatPosted
        self.recordID = ckRecord.recordID
        if let isBlocked = ckRecord[OctoberPostConstants.isBlockedKey] as? [String] {
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
    convenience init(octoberPost: OctoberPost) {
        self.init(recordType: OctoberPostConstants.recordKey, recordID: octoberPost.recordID)
        self.setValue(octoberPost.title, forKey: OctoberPostConstants.titleKey)
        self.setValue(octoberPost.description, forKey: OctoberPostConstants.descriptionKey)
        self.setValue(octoberPost.timestamp, forKey: OctoberPostConstants.timestampKey)
        self.setValue(octoberPost.imageAsset, forKey: OctoberPostConstants.imageKey)
        self.setValue(octoberPost.userProfileImageAsset, forKey: OctoberPostConstants.userProfileImageKey)
        self.setValue(octoberPost.userReference, forKey: OctoberPostConstants.userReferenceKey)
        self.setValue(octoberPost.userThatPosted, forKey: OctoberPostConstants.userThatPostedKey)
        
        if !octoberPost.isBlocked.isEmpty {
            self.setValue(octoberPost.isBlocked, forKey: OctoberPostConstants.isBlockedKey)
        }
    }
}
