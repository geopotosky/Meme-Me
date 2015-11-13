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
    @IBOutlet weak var deleteButtonLabel: UIBarButtonItem!
    
    var memes: [Memes]!
    var memeIndex:Int!
    var memeIndexPath: NSIndexPath!
    
    var editMemeFlag: Bool!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes


        //-Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let meme = fetchedResultsController.objectAtIndexPath(memeIndexPath) as! Memes
        
        let finalImage = UIImage(data: meme.memedImage!)
        self.imageView!.image = finalImage
        
    }

    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Fetched Results Controller
    
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
    }
    
    
    @IBAction func editMeme(sender: UIBarButtonItem) {

        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController

        controller.memeIndexPath2 = memeIndexPath
        controller.memeIndex2 = memeIndex
        controller.editMemeFlag = true
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    //function - Delete the selected meme
    @IBAction func deleteMemeButton(sender: UIBarButtonItem) {
    //func deleteMeme(){

        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Meme?", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Delete Meme action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Meme", style: .Default) { action -> Void in
//            let object = UIApplication.sharedApplication().delegate
//            let appDelegate = object as! AppDelegate
            print(self.memeIndex)
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
