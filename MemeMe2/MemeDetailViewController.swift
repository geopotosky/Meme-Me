//
//  MemeDetailViewController.swift
//  MemeMe2
//
//  Created by George Potosky on 5/5/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class MemeDetailViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    
    //var memedImage : UIImage!
    var memes: [Memes]!
//    var memes: Memes!
    var memeIndex:Int!
    var memeIndexPath: NSIndexPath!
    //var memedImage: NSData!
//    var memedImage2: NSData!
//    var memedImage3: NSData!
    
    var editMemeFlag: Bool!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        println("MemeDetailVC viewDidLoad")
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteMeme")
        
//        let b1 = UIBarButtonItem(barButtonSystemItem: .Trash, target: self,  action: "deleteMeme")
//        let b2 = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editMeme")
//        let buttons = [b1, b2] as NSArray
//        self.navigationItem.rightBarButtonItems = [b1, b2]
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
//        //println("memes.count: \(memes.count)")
//        println("memeIndex: \(memeIndex)")
//        println("memeIndexPath: \(memeIndexPath)")
//        println("editMemeFlag: \(editMemeFlag)")
        
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("MemeDetailVC viewWillAppear")
        
        //println("memes.count: \(memes.count)")
        println("memeIndex: \(memeIndex)")
        println("memeIndexPath: \(memeIndexPath)")
        println("editMemeFlag: \(editMemeFlag)")
        
        //Get shared model info
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate = object as! AppDelegate
//        memes = appDelegate.memes
        
        let meme = fetchedResultsController.objectAtIndexPath(memeIndexPath) as! Memes
        
        println(meme.textTop)
        
        let finalImage = UIImage(data: meme.memedImage!)
        self.imageView!.image = finalImage
        
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
    
    
    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeTableViewController") as! MemeTableViewController
//        
//        self.presentViewController(controller, animated: true, completion: nil)
//        let controller = self.navigationController!.viewControllers[1] as! UIViewController
//        self.navigationController?.popToViewController(controller, animated: true)
        
    }
    @IBAction func editMeme(sender: UIBarButtonItem) {
//    }
//    func editMeme(){
        println("Getting ready to edit the Meme")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        
        //controller.memes = memes[index]
        //controller.memes = self.memes

        controller.memeIndexPath2 = memeIndexPath
        controller.memeIndex2 = memeIndex
        controller.editMemeFlag = true
        
        //controller.memedImage2 = meme.memedImage
        
        self.presentViewController(controller, animated: true, completion: nil)
        //self.navigationController!.pushViewController(controller, animated: true)
        
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
//        controller.memeIndexPath2 = memeIndexPath
//        controller.memeIndex2 = memeIndex
//        controller.editMemeFlag = true
//        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //function - Delete the selected meme
    //@IBAction func deleteMemeButton(sender: UIButton) {
    func deleteMeme(){
        println("delete button pushed.")

        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Meme?", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Delete Meme action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Meme", style: .Default) { action -> Void in
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            println(self.memeIndex)
            //appDelegate.memes.removeAtIndex(self.memeIndex)
            
            let meme = self.fetchedResultsController.objectAtIndexPath(self.memeIndexPath) as! Memes
            self.sharedContext.deleteObject(meme)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            //appDelegate.memes.removeAtIndex(self.memeIndex)
            self.navigationController!.popViewControllerAnimated(true)
        }
        actionSheetController.addAction(deleteAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
}
