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

//------------------------------------------------------------------------------------

//When working with the keyboard, the notifications we care about are keyboardWillHideNotification and keyboardWillChangeFrameNotification
//first will be sent when the keyboard has finished hiding, and the second will be shown when any keyboard state change happens

//addObserver() method, which takes four parameters: the object that should receive notifications (it's self), the method that should be called, the notification we want to receive, and the object we want to watch. We're going to pass nil to the last parameter, meaning "we don't care who sends the notification."



//1.the dictionary will contain a key called UIResponder.keyboardFrameEndUserInfoKey telling us the frame of the keyboard after it has finished animating. This will be of type NSValue, which in turn is of type CGRect. The CGRect struct holds both a CGPoint and a CGSize, so it can be used to describe a rectangle

//2.contentInset the amount to push its content from edges...if = 0 then occupy all space

//setting the inset of a text view is done using the UIEdgeInsets struct, which needs insets for all four edges. I'm using the text view's content inset for its scrollIndicatorInsets to save time

//-----------------------

//Our own preprocessing JavaScript runs before our Swift code.
//This is where we can send in any data about the page.

//When our Swift extension finishes we can send values back to JavaScript.
//Anything we send back is then made available to our action file




import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
        
        //get a reference to the default notification center
        let notificationCenter = NotificationCenter.default
        //addObserver
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        
        
        //When extension is created, its extensionContext lets us control how it interacts with the parent app. In the case of inputItems this will be an array of data the parent app is sending to our extension to use. We only care about this first item in this project, and even then it might not exist, so we conditionally typecast using if let and as?
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            
            // input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider
            if let itemProvider = inputItem.attachments?.first  {
                
                //ask the item provider to actually provide us with its item, but you'll notice it uses a closure so this code executes asynchronously. the method will carry on executing while the item provider is busy loading and sending us its data
                
                //When loadItem(forTypeIdentifier:) completes it will call a closure so we can act on its data
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
    //receive a parameter that is of type Notification. Notification will include the name of the notification as well as a Dictionary containing notification-specific information called userInfo
    @objc func adjustForKeyboard(notification: Notification) {
        //1.tells us the size of keyboard
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        //convert NSValue to rectangle
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        //convert the rectangle to our view's co-ordinates
        //because rotation isn't factored into the frame,
        //so if the user is in landscape we'll have the width and height flipped
        //using the convert() method will fix that
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        //check we're hiding or not
        if notification.name == UIResponder.keyboardWillHideNotification {
            //2.make sure our textView takes all the available space
            script.contentInset = .zero
        } else {//in did change frame/keyboard is being used
           
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            //-view.safeAreaInsets.bottom
            //on oled iphones there/s extra space we need to remvoe
            
        }
        //controls how much margin apply to little scroll bar on the right edge of textView when the scroll
        
        //it will match always the side of our textView
        script.scrollIndicatorInsets = script.contentInset
        
        //make our textView to scroll down to show whatever user's hand tapped on
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    
    @objc func addScript() {
        let ac = UIAlertController(title: "Choodr a script", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Pop up saying hello world", style: .default) { [weak self] action in
            self?.script.text = """
alert("hello world")
"""
        }
        ac.addAction(action)
        present(ac,animated: true)
        
    }
}
