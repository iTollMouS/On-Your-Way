//
//  FileStorage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import FirebaseStorage
import ProgressHUD


let storage = Storage.storage()


// MARK: - FileStorage

class FileStorage {
    
    
    // MARK: - uploadImage
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping(_ imageUrl: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: storageReferenceKey).child(directory)
        
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {return}
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                ProgressHUD.show("Error while uploading image \(error.localizedDescription)")
                return
            }
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            storageRef.downloadURL { (imageUrl, error) in
                if let error = error {
                    ProgressHUD.show("Error while uploading image \(error.localizedDescription)")
                    return
                }
                guard let imageUrl =  imageUrl else {return}
                completion(imageUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
        ProgressHUD.dismiss()
    }
    
    
    // MARK: - downloadImage
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)

        if fileExistsAtPath(path: imageFileName) {
            //get it locally
//            print("We have local image")
            
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage(named: "avatar"))
            }
            
        } else {
            //download from FB
//            print("Lets get from FB")

            if imageUrl != "" {
                
                let documentUrl = URL(string: imageUrl)
                
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        
                        //Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    } else {
                        print("no document in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - saveFileLocally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
}



// MARK: - Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}
func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}

func fileNameFrom(fileUrl: String) -> String {
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}
