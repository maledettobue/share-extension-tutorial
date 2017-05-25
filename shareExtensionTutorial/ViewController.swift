//
//  ViewController.swift
//  shareExtensionTutorial
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.maledettobue.container") {
            
            let newDirectory = directory.appendingPathComponent("my_dir")
            
            let directoryContents = try? FileManager.default.contentsOfDirectory(at: newDirectory, includingPropertiesForKeys: nil, options: [])
            
            print(directoryContents ?? "File is not here")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

