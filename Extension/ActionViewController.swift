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

// NSDictionary you don't need to declare or even know what data types it holds
import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        //When extension is created, its extensionContext lets us control how it interacts with the parent app. In the case of inputItems this will be an array of data the parent app is sending to our extension to use. We only care about this first item in this project, and even then it might not exist, so we conditionally typecast using if let and as?
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            
            // input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider
            if let itemProvider = inputItem.attachments?.first  {
                
                //ask the item provider to actually provide us with its item, but you'll notice it uses a closure so this code executes asynchronously. the method will carry on executing while the item provider is busy loading and sending us its data
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String){//1
                    [weak self] (dict, error) in
                    
                    
                    //nothing in  dictionary other than the data we sent from JavaScript, and that's stored in a special key called NSExtensionJavaScriptPreprocessingResultsKey
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    
                    //We sent a dictionary of data from JavaScript, so we typecast javaScriptValues as an NSDictionary
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print(javaScriptValues)
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    //needed because the closure being executed as a result of loadItem(forTypeIdentifier:) could be called on any thread, and we don't want to change the UI unless we're on the main thread
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                    
                }
            }
        }
        
    }
    
    @IBAction func done() {
        //thing we'll pass back
        //Create a new NSExtensionItem object that will host our items
        let item = NSExtensionItem()
        //passing our script
        //Create a dictionary containing the key "customJavaScript" and the value of our script
        let argument: NSDictionary = ["customJavaScript": script.text]
        
        //thing to pass to finalize in js file
        //Put that dictionary into another dictionary with the key NSExtensionJavaScriptFinalizeArgumentKey.
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        //Wrap the big dictionary inside an NSItemProvider object with the type identifier kUTTypePropertyList.
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        //Place that NSItemProvider into our NSExtensionItem as its attachments
        item.attachments = [customJavaScript]
        //Call completeRequest(returningItems:), returning our NSExtensionItem
        extensionContext?.completeRequest(returningItems: [item])


    }
    
}
