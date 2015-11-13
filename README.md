==============
Meme-Me README
==============


“Meme Me” is a meme creator. This is project #2 from the Udacity iOS Development course. This version will save the memes.


----------------
Sent Memes Scene
----------------

Files:
------
MemeTableViewController.swift
MemeCollectionViewController.swift
MemeCollectionViewCell.swift

The Sent Meme scenes display the list of memes currently saved. There are 2 views: Table view and Collection view. Both behave the same way and have similar options.

Sent Memes Table Scene:

How to use the Sent Memes Table scene:

Tap (if necessary) the Table icon in the bottom tab bar to view the My Events table view.

•	Each Meme shows the selected Meme image and the TOP Meme text.
•	Tap the Meme to push to the main Meme view scene.

•	Tap the “+” to add a new Meme.

•	Tap the “Edit” button to delete one or more Meme. Tap the red circle to display the Delete button. Tap the Delete button to delete the item. Tap “Done” when editing is complete.

Sent Memes Collection Scene:

How to use the Sent Memes Collection scene:

Tap (if necessary) the Collection icon in the bottom tab bar to view the My Events collection view.

•	Each Meme shows the selected Meme background image.

•	Tap the event to push to the main countdown view.

•	Tap the “+” to add a new event.


---------------
Meme View Scene
---------------

Files:
------
MemeDetailViewController.swift

The Meme Detail Viewer scene displays the Meme is it’s own scene. 

How to use the Meme Details scene:

•	Tap the trash can icon to delete the current event.


-----------------
Meme Editor Scene
-----------------

Files:
------
MemeEditerViewController.swift


The Meme Editor scene provides a way to add new Memes. The user is presented with a new scene.

How to use the Add/Edit Event scene:

•	Tap the TOP text field to add Meme text on the top of the image.
•	Tap the BOTTOM text field to add Meme text on the bottom of the image.
•	Tap the Album button to select a picture from your device library.
•	Tap the camera icon to take a picture to be used for the Meme.
•	Tap “Cancel” to exit out of the Meme editor.



----------------
Other App Files:
----------------

Delegate Files:
---------------

AppDelegate.swift: Default delegate file
TopTextDelegate.swift: Text field delegate file
BottomTextDelegate.swift: Text field delegate file


Object Files:
-------------

Memes.swift: 
•	Primary object for storing Meme data


