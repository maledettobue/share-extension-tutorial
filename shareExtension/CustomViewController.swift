//
//  CustomViewController.swift
//  com.maledettobue.shareExtension
//

import Foundation
import UIKit
import MobileCoreServices

class CustomViewContoller:UIViewController {
    
    // MARK: - outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - members
    var selectedImage:UIImage!
    var destinationDirectory:URL!
    var originalFileName:String!
    var image:UIImage!
    var imageData:NSData!
    
    // MARK: - actions
    @IBAction func cancelButtonAction(_ sender: Any) {
        // cancel
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        // save
        do {
            let filename = self.destinationDirectory.appendingPathComponent(originalFileName)
            try self.imageData.write(to: filename)
        } catch {
            print(error)
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        
    }
    
    private func isValidImageSize(img:UIImage)->Bool{
        return img.size.width<100
    }
    
    private func displayAlert(){
        
        let alertController = UIAlertController(title: "!", message:
            "Wrong image dimensions", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler:{(action) -> Void in self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)}))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // FIXME: - fix this, very improvable / don't do this at home   :-)
    override func viewDidLoad() {
        
        print("loaded shared extension storyboard")
        
        // let darkBlur:UIBlurEffect = UIBlurEffect()
        // let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        // let blurView = UIVisualEffectView(effect: darkBlur)
        
        let blurView = UIView()
        blurView.backgroundColor = UIColor.black
        blurView.alpha = 0.3
        blurView.frame = self.view.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)
        self.view.sendSubview(toBack: blurView)
        
        let fileManager = FileManager.default
        
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.maledettobue.container") {
            
            print("---------------------")
            print(directory)
            print("---------------------")
            
            self.destinationDirectory = directory.appendingPathComponent("my_dir")
            
            do {
                try fileManager.createDirectory(at: self.destinationDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error)
            }
            
            // extension content
            guard let content = self.extensionContext!.inputItems[0] as? NSExtensionItem else {return}
            guard let attachments = content.attachments as? [NSItemProvider] else {return}
            
            // cast. kUTTYpeImage is a CFString (it contains a Unicode string along with its length)
            let contentType = kUTTypeImage as String
            
            // attachments is an array of elements typed as NSItemProvider
            // (the loop could be avoided in this case)
            for attachment in attachments {
                
                // items in content.attachments can be images, URL, videos, etc.
                if attachment.hasItemConformingToTypeIdentifier(contentType) {
                    
                    // move to a background thread to do potentially long running task
                    DispatchQueue.global(qos: .userInteractive).async {
                        
                        // item load
                        attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in
                            
                            if let url = data as? URL, error == nil {
                                
                                // name of the file (eg. "photo.jpg")
                                self.originalFileName = url.lastPathComponent
                                
                                if let imageData = NSData(contentsOf: url) {
                                    
                                    // save imageData
                                    self.imageData = imageData
                                    
                                    // main
                                    DispatchQueue.main.async {
                                        
                                        self.imgView.image = UIImage(data:imageData as Data)
                                        self.imgView.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
                                        
                                        let img = UIImage(data:imageData as Data)!
                                        
                                        // very basic validation
                                        if(self.isValidImageSize(img: img)){self.displayAlert()}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // end viewDidLoad
    
}
