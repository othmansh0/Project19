//
//  ActionViewController.swift
//  Extension
//
//  Created by othman shahrouri on 9/23/21.
//


//1.accept two parameters: the dictionary that was given to us by the item provider, and any error that occurred
//dict contains imp stuff tells us what was provided to us by ios


//-------------------------------------------------------------------------------

//extensions, this plist also describes what data you are willing to accept and how it should be processed

//NSExtensionMainStoryboard modifies the way our extension behaves

//truepredict means our extension will work with any kind of data being shared from any extension compatible app, instead we want only when we have a webpage shared with us


//Adding NSExtensionActivationSupportsWebPageWithMaxCount value to the dictionary means that we only want to receive web pages

//NSExtensionJavaScriptPreprocessingFile", then give it the value "Action". This tells iOS that when our extension is called, we need to run the JavaScript preprocessing file called Action.js, which will be in our app bundle


import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //When extension is created, its extensionContext lets us control how it interacts with the parent app. In the case of inputItems this will be an array of data the parent app is sending to our extension to use. We only care about this first item in this project, and even then it might not exist, so we conditionally typecast using if let and as?
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            
           // input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider
            if let itemProvider = inputItem.attachments?.first  {
                
                //ask the item provider to actually provide us with its item, but you'll notice it uses a closure so this code executes asynchronously. the method will carry on executing while the item provider is busy loading and sending us its data
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String){//1
                    [weak self] (dict, error) in
                    
                    
                }
            }
        }
        
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
