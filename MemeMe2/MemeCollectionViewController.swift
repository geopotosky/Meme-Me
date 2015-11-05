//
//  MemeCollectionViewController.swift
//  MemeMe2
//
//  Created by George Potosky on 5/5/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class MemeCollectionViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    //Scene outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    
    
    //Meme variables
    var memes: [Memes]!
//    var memes: Memes!
    var memeIndex: Int!
    
    var editMemeFlag: Bool!
    var editButtonFlag: Bool!

    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var cancelButton: UIBarButtonItem!
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        memes = fetchAllMemes()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editButton")
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        bottomButton.hidden = true
        
        // Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        
        fetchedResultsController.delegate = self
        
//        //* - Bottom Button updater
//        updateBottomButton()
        
    }
    
    
    // Layout the collection view cells
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that there are 3 cells accrosse
        // with white space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        
        let screenWidth = self.collectionView?.bounds.size.width
        let totalSpacing = layout.minimumInteritemSpacing * 3.0
        let imageSize = (screenWidth! - totalSpacing)/3.0
        layout.itemSize = CGSize(width: imageSize, height: imageSize)
        
        collectionView.collectionViewLayout = layout
        
    }
    
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        editButtonFlag = true
        
        //Get shared model info
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate = object as! AppDelegate
//        memes = appDelegate.memes

        //Brute Force Reload the scene to view collection updates
        self.collectionView.reloadData()
        
        
    }
    
    
//    //* - GEO: Add the "sharedContext" convenience property
//    lazy var sharedContext: NSManagedObjectContext = {
//        return CoreDataStackManager.sharedInstance().managedObjectContext!
//        }()
    
    
    func editButton(){
        println("Hello Edit Button")
        
        if self.navigationItem.leftBarButtonItem?.title == "Done" {
            
            //* - Recreate navigation Back button and change name to OK
            self.navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editButton")
            self.navigationItem.leftBarButtonItem = newBackButton
            bottomButton.hidden = true
            editButtonFlag = true
            
        } else {
            
            //* - Recreate navigation Back button and change name to OK
            self.navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "editButton")
            self.navigationItem.leftBarButtonItem = newBackButton
        
            bottomButton.hidden = false
            editButtonFlag = false
            //updateBottomButton()
        }
    }
    
    
    //* - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
//        let CellIdentifier = "MemeCell"
        
        // Here is how to replace the actors array using objectAtIndexPath
        //let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
        
//        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        // This is the new configureCell method
        //configureCell(cell, withMeme: meme)
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if editButtonFlag == false {
            
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            
        //let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            //cell.cellOverlay.backgroundColor = UIColor.purpleColor()
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        //self.configureCell(cell, atIndexPath: indexPath)
            //configureCell(cell, withMeme: meme)
            configureCell(cell, atIndexPath: indexPath)
            
        
        // And update the buttom button
        //updateBottomButton()
        
        } else {
        
        let controller =
        storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        // Similar to the method above
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
        
        controller.memes = self.memes
        controller.memeIndexPath = indexPath
        controller.memeIndex = indexPath.row
        //controller.memedImage = meme.memedImage
        
        self.navigationController!.pushViewController(controller, animated: true)
            
        }
        
    }

    //* - Configure Cell
    
    //func configureCell(cell: MemeCollectionViewCell, withMeme meme: Memes) {
    func configureCell(cell: MemeCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Memes
        
        let memeImage2 = meme.memedImage
        let finalImage = UIImage(data: memeImage2!)
        
        //cell.textLabel!.text = meme.textTop
        cell.memeImageView!.image = finalImage
        println("show it now")
        
        if let index = find(self.selectedIndexes, indexPath) {
            cell.memeImageView!.alpha = 0.5
        } else {
            cell.memeImageView!.alpha = 1.0
        }
    }
    
    
    //* - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Memes")
        //fetchRequest.predicate = NSPredicate(format: "pins == %@", self.pins);
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textTop", ascending: true)]
        //fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        }()
    
    
    //* - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to
    // create three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        //println("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each picture object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            //println("Insert an item")
            // Here we are noting that a new picture instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            //println("Delete an item")
            // Here we are noting that a picture instance has been deleted from Core Data. We keep remember its index
            // path so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath"
            // parameter has value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            //println("Update an item.")
            // We don't expect picture instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            //println("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //println("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    
    //* - Click Button Decision function
    
    @IBAction func buttonButtonClicked() {
        
//        bottomButton.enabled = false
        
//        if selectedIndexes.isEmpty {
//            self.navigationItem.leftBarButtonItem?.enabled = false
//            deleteAllPictures()
//        } else {
            deleteSelectedPictures()
            
//        }
    }
    
    //* - Delete All Pictures before adding new pictures function
    
    func deleteAllPictures() {
        
        for meme in self.fetchedResultsController.fetchedObjects as! [Memes] {
            
            self.sharedContext.deleteObject(meme)
        }
        
    }
    
    //* - Delete Selected Picture function
    
    func deleteSelectedPictures() {
        var memesToDelete = [Memes]()
        
        for indexPath in selectedIndexes {
            memesToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Memes)
            
        }
        
        for meme in memesToDelete {
            sharedContext.deleteObject(meme)
//            bottomButton.title = "New Collection"
        }
        
        selectedIndexes = [NSIndexPath]()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    //* - Update the button label based on selection criteria
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            //bottomButton.title = "Remove Selected Pictures"
            bottomButton.titleLabel?.text = "Remove Selected Pictures"
            
            
        } else {
            //bottomButton.title = "New Collection"
            bottomButton.titleLabel?.text = "Clear All Memes"
        }
    }

    
    
//*---------- OLD CODE ---------------------------*//
    
//    func fetchAllMemes() -> [Memes] {
//        let error: NSErrorPointer = nil
//        
//        // Create the Fetch Request
//        let fetchRequest = NSFetchRequest(entityName: "Memes")
//        
//        // Execute the Fetch Request
//        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
//        
//        println("Fetching Memes")
//        
//        // Check for Errors
//        if error != nil {
//            println("Error in fectchAllActors(): \(error)")
//        }
//        
//        // Return the results, cast to an array of Meme objects
//        return results as! [Memes]
//    }
    
    
//    //Function - Collection View Data Source
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
////        //Check to see if you have any memes. If not, go directly to the Edit Screen.
////        if memes.count == 0 {
////           
////            let actionSheetController: UIAlertController = UIAlertController(title: "Zippo!", message: "No Memes. Press OK to create a Meme", preferredStyle: .ActionSheet)
////            
////            //Create and add the OK Meme action
////            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
////                
////                let storyboard = self.storyboard
////                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
////                self.presentViewController(controller, animated: true, completion: nil)
////            }
////            actionSheetController.addAction(okAction)
////            
////            //Present the AlertController
////            self.presentViewController(actionSheetController, animated: true, completion: nil)
////            
////        }
//        return memes.count
//    }
//    
//    //Set the collection view cell
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        //Set the image for the collection
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
//        let meme = memes[indexPath.item]
//        
//        let memeImage2 = meme.memedImage
//        let finalImage = UIImage(data: memeImage2!)
//        
//        //cell.textLabel!.text = meme.textTop
//        cell.memeImageView!.image = finalImage
//        
//        //cell.memeImageView?.image = memeElement.memedImage as? UIImage
//        return cell
//    }
//    
//    //If a collection cell is selected, pull up the Meme Details page and display the selected Meme
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
//    {
//        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as! MemeDetailViewController
////        detailController.memes = self.memes[indexPath.row]
////        detailController.memeIndex = indexPath.row
//        
//        self.navigationController!.pushViewController(detailController, animated: true)
//        
//
//    }

    
    
    //Button Function - Create a New Meme
    @IBAction func memeEditButton(sender: UIBarButtonItem) {
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        controller.editMemeFlag = false
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
}

