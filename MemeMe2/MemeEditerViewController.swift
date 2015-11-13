//
//  MemeEditerViewController.swift
//  MemeMe2
//
//  Created by George Potosky on 5/5/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate{
    
    //Edit Screen outlets
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var toolbarObject: UIToolbar!
    @IBOutlet weak var navbarObject: UINavigationBar!
    @IBOutlet weak var shareMemeButton: UIBarButtonItem!
    @IBOutlet weak var cancelMemeButton: UIBarButtonItem!
    
    //set the textfield delegates
    let topTextDelegate = TopTextDelegate()
    let bottomTextDelegate = BottomTextDelegate()
    
    //Meme variables
    var memedImage : UIImage!
    //var memes: Memes!
    var memes: [Memes]!
    
    
    var memeIndex2:Int!
    var memeIndexPath2: NSIndexPath!
    var memedImage2: NSData!
//    var memedImage3: UIImage!
    
    var editMemeFlag: Bool!
    
    
    //Meme Font Attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.0
    ]
    
    //setup the Meme Editor text fields
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes

        
        //Add font attributes to top and bottom text fields
        self.textFieldTop.defaultTextAttributes = memeTextAttributes
        self.textFieldBottom.defaultTextAttributes = memeTextAttributes
        
        //Set starting textfield default values
        self.textFieldTop.text = "TOP"
        self.textFieldTop.textAlignment = NSTextAlignment.Center
        self.textFieldBottom.text = "BOTTOM"
        self.textFieldBottom.textAlignment = NSTextAlignment.Center
        
        //textfield delegate values
        self.textFieldTop.delegate = topTextDelegate
        self.textFieldBottom.delegate = bottomTextDelegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        print("editMemeFlag: \(self.editMemeFlag)")
        //println("New Memes Count: \(appDelegate.memes.count)")
        
        if editMemeFlag == false {
            if memes.count == 0 {
                
                cancelMemeButton.enabled = false
            } else {
                cancelMemeButton.enabled = true
            }
        } else {
            cancelMemeButton.enabled = true
            //Enable the Sharing Button
            shareMemeButton.enabled = true
            let meme = fetchedResultsController.objectAtIndexPath(memeIndexPath2) as! Memes
            
            //* - Add Selected Meme attributes and populate Editor fields
            self.textFieldTop.text = meme.textTop
            self.textFieldBottom.text = meme.textBottom
            imageViewPicker.image = UIImage(data: meme.originalImage!)
            
        }
        
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Disable the CAMERA if you are using a simulator without a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Subscribe to the Keyboard notification
        self.subscribeToKeyboardNotifications()  //make the call to subscribe to keyboard notifications
    }

    //Perform when view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Unsubscribe from the keyboard notifications
        self.unsubscribeFromKeyboardNotifications() //make the call to unsubscribe to keyboard notifications
    }
    
    
    //* - GEO: Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Memes")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textTop", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    
    //Button to Pick an image from the library
    @IBAction func PickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Select an image for the Meme
    func imagePickerController(imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewPicker.image = originalImage
            }
            //Enable the Sharing Button
            shareMemeButton.enabled = true
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Cancel the picked image
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Button to Take a Picture with Camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Subscribe to Keyboard appearing and hiding notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Move screen up to prevent keyboard overlap
    func keyboardWillShow(notification: NSNotification) {
        if textFieldBottom.isFirstResponder(){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //Move screen back down after done using keyboard
    func keyboardWillHide(notification: NSNotification) {
        if textFieldBottom.isFirstResponder(){
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    //Calculate the keyboard height and place in variable
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //Unsubscribe from Keyboard Appearing and hiding notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    //Generate the Meme
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        navbarObject.hidden = true
        toolbarObject.hidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        navbarObject.hidden = false
        toolbarObject.hidden = false
        
        return memedImage
        
    }
    
    //Save the Meme
    func saveMeme() {
        
        //Create the Meme
        let origImage = UIImageJPEGRepresentation(imageViewPicker.image!, 100)
        let memedImage2 = UIImageJPEGRepresentation(memedImage, 100)
        print("saveMeme memedImage: \(memedImage)")
        
        //let memedImage3 = memedImage2
        
        let memeToBeAdded = Memes(textTop: textFieldTop.text!, textBottom: textFieldBottom.text!, originalImage: origImage, memedImage: memedImage2, context: sharedContext)
        
        // Add it to the shared Memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        if editMemeFlag == true {
            print("Remove Selected Object")
            print(self.memeIndexPath2)
            let meme = self.fetchedResultsController.objectAtIndexPath(self.memeIndexPath2) as! Memes
            self.sharedContext.deleteObject(meme)
            CoreDataStackManager.sharedInstance().saveContext()
            
//            let storyboard = self.storyboard
//            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            
            let controller =
            storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            
            //let meme = self.fetchedResultsController.objectAtIndexPath(self.memeIndexPath2) as! Memes
            controller.editMemeFlag = true
            //controller.memes = self.memes
            controller.memeIndexPath = self.memeIndexPath2
            controller.memeIndex = self.memeIndex2
            //controller.memedImage = NSData(data: self.memedImage2)
            //println("controller.memedImage: \(controller.memedImage)")
            
            self.presentViewController(controller, animated: true, completion: nil)
            //self.navigationController!.pushViewController(controller, animated: true)
            
//            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
//            self.presentViewController(controller, animated: true, completion: nil)
            
            
        } else {
            
            // And add append the actor to the array as well
            print("Save Meme")
//            appDelegate.memes.append(memeToBeAdded)
            memes.append(memeToBeAdded)
            
//            memeToBeAdded.memes = self.memes
            
            
            print("Newly Saved Meme Index: \(appDelegate.memes.last)")
            print("New Memes Count: \(appDelegate.memes.count)")
        
            //memeIndexPath2 = appDelegate.memes.last
        
//        self.memes?.append(memeToBeAdded)
        
        
            // Finally we save the shared context, using the convenience method in
            // The CoreDataStackManager
            print("Saving Memes")
            CoreDataStackManager.sharedInstance().saveContext()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    //Share the Meme
    @IBAction func shareMyMeme(sender: AnyObject) {
        
        //Create a memed image, pass it to the activity view controller.
        self.memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [self.memedImage!], applicationActivities: nil)
        
        //If the user completes an action in the activity view controller,
        //save the Meme to the shared storage.
        activityVC.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.saveMeme()
                //println("Newly Saved Meme Index: \(appDelegate.memes.last)")
                //self.dismissViewControllerAnimated(true, completion: nil)
                
//                let storyboard = self.storyboard
//                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
//                
//                //let meme = self.fetchedResultsController.objectAtIndexPath(self.memeIndexPath2) as! Memes
//                controller.editMemeFlag = true
//                //controller.memes = self.memes
//                controller.memeIndexPath = self.memeIndexPath2
//                controller.memeIndex = self.memeIndex2
//                //controller.memedImage = self.memedImage2
//                //println("controller.memedImage: \(controller.memedImage)")
//                
//                self.presentViewController(controller, animated: true, completion: nil)
                
            }
        }
        
        self.presentViewController(activityVC, animated: true, completion: nil)
        
    }
    
    //Cancel the Editor and go back to the previous scene
    @IBAction func CancelEditorButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

