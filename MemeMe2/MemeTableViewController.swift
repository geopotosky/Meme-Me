//
//  MemeTableViewController.swift
//  MemeMe2
//
//  Created by George Potosky on 5/5/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class MemeTableViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var memes: [Memes]!
//    var memes: Memes!
    var memeIndex: Int!
    var memeIndexPath: NSIndexPath!
    var editMemeFlag: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        memes = fetchAllMemes()
//        getMemes()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addActor")
        
//                        let b1 = UIBarButtonItem(barButtonSystemItem: .Trash, target: self,  action: "barButtonItemClicked")
//                        let b2 = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "barButtonItemClicked")
//                        let buttons = [b1, b2] as NSArray
//                        self.navigationItem.leftBarButtonItems = [b1, b2]
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self

    }
    
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get shared model info
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate = object as! AppDelegate
//        memes = appDelegate.memes
        
        //Brute Force Reload the scene to view table updates
        self.tableView.reloadData()
        
//        println("Meme counter: \(memes.count)")

    }
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
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

    
    
    //* - Configure Cell
    
    func configureCell(cell: UITableViewCell, withMeme meme: Memes) {
    
        let memeImage2 = meme.memedImage
        let finalImage = UIImage(data: memeImage2!)
        
        cell.textLabel!.text = meme.textTop
        cell.imageView!.image = finalImage
        println("show it now")
        
    }

    

    //function - Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        //println("First memes.count: \(memes.count)")
        
        
        //Check to see if you have any memes. If not, go directly to the Edit Screen.
        if sectionInfo.numberOfObjects == 0 {
            
            let actionSheetController: UIAlertController = UIAlertController(title: "Zippo!", message: "No Memes. Press OK to create a Meme", preferredStyle: .Alert)
            
            //Create and add the Delete Meme action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                
                let storyboard = self.storyboard
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
                controller.editMemeFlag = false
                self.presentViewController(controller, animated: true, completion: nil)
            }
            actionSheetController.addAction(okAction)
            
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
        
        return sectionInfo.numberOfObjects
        
    }
    
    //Set the table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = "MemeCell"
        
        // Here is how to replace the actors array using objectAtIndexPath
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        // This is the new configureCell method
        configureCell(cell, withMeme: meme)
        
        return cell
    }
    
    
    //If a table entry is selected, pull up the Meme Details page and display the selected Meme
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller =
        storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        // Similar to the method above
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
        
        controller.memes = self.memes
        controller.memeIndexPath = indexPath
        controller.memeIndex = indexPath.row
        //controller.memedImage = meme.memedImage
        //controller.memedImage3 = meme.memedImage
        
        //self.navigationController!.pushViewController(controller, animated: true)
        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                // Here we get the actor, then delete it from core data
                let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
                sharedContext.deleteObject(meme)
                CoreDataStackManager.sharedInstance().saveContext()
                
            default:
                break
            }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            case .Update:
                let storyboard = self.storyboard
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
                controller.memeIndexPath2 = memeIndexPath
                controller.memeIndex2 = memeIndex
                controller.editMemeFlag = true
                self.presentViewController(controller, animated: true, completion: nil)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell?
                let meme = controller.objectAtIndexPath(indexPath!) as! Memes
                self.configureCell(cell!, withMeme: meme)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
    
    
    //Button Function - Create a New Meme
    @IBAction func memeEditButton(sender: UIBarButtonItem) {
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        
        //controller.memedImage = self.memeImage
        controller.editMemeFlag = false
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
}
