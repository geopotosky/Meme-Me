//
//  BottomTextDelegate.swift
//  MemeMe2
//
//  Created by George Potosky on 5/5/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

class BottomTextDelegate: NSObject, UITextFieldDelegate {
    
    //Ask the delegate if the textfield should change
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var newText: NSString = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return true;
    }
    
    //Let the delegate know that editing has begun
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //Check to see if the initial value of the textfield is TOP. If it is, clear it.
        if textField.text == "BOTTOM" {
            textField.text = ""
        }
        
    }
    
    //Ask the delegate if the RETURN key should be processed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    
}
