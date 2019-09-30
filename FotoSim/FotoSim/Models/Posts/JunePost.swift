//
//  JunePost.swift
//  FotoSim
//
//  Created by Blake kvarfordt on 9/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit
import CloudKit

struct JunePostConstants {
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

class JunePost {
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
        guard let title = ckRecord[JunePostConstants.titleKey] as? String,
            let description = ckRecord[JunePostConstants.descriptionKey] as? String,
            let timestamp = ckRecord[JunePostConstants.timestampKey] as? Date,
            let userReference = ckRecord[JunePostConstants.userReferenceKey] as? CKRecord.Reference,
            let imageAsset = ckRecord[JunePostConstants.imageKey] as? CKAsset,
            let userThatPosted = ckRecord[JunePostConstants.userThatPostedKey] as? String,
            let userProfileImageAsset = ckRecord[JunePostConstants.userProfileImageKey] as? CKAsset else { return nil }
        
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.userReference = userReference
        self.userThatPosted = userThatPosted
        self.recordID = ckRecord.recordID
        if let isBlocked = ckRecord[JunePostConstants.isBlockedKey] as? [String] {
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
    convenience init(junePost: JunePost) {
        self.init(recordType: JunePostConstants.recordKey, recordID: junePost.recordID)
        self.setValue(junePost.title, forKey: JunePostConstants.titleKey)
        self.setValue(junePost.description, forKey: JunePostConstants.descriptionKey)
        self.setValue(junePost.timestamp, forKey: JunePostConstants.timestampKey)
        self.setValue(junePost.imageAsset, forKey: JunePostConstants.imageKey)
        self.setValue(junePost.userProfileImageAsset, forKey: JunePostConstants.userProfileImageKey)
        self.setValue(junePost.userReference, forKey: JunePostConstants.userReferenceKey)
        self.setValue(junePost.userThatPosted, forKey: JunePostConstants.userThatPostedKey)
        
        if !junePost.isBlocked.isEmpty {
            self.setValue(junePost.isBlocked, forKey: JunePostConstants.isBlockedKey)
        }
    }
}
