//
//  IQKeyboardReturnKeyHandler.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

let kIQTextField                =   "kIQTextField"
let kIQTextFieldDelegate        =   "kIQTextFieldDelegate"
let kIQTextFieldReturnKeyType   =   "kIQTextFieldReturnKeyType"

/*  @abstract   Manages the return key to work like next/done in a view hierarchy.    */
class IQKeyboardReturnKeyHandler: NSObject , UITextFieldDelegate, UITextViewDelegate {
   
    /*! @abstract textField's delegates.    */
    var delegate: protocol<UITextFieldDelegate, UITextViewDelegate>?
    
    /*! @abstract It help to choose the lastTextField instance from sibling responderViews. Default is IQAutoToolbarBySubviews. */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /*! @abstract Set the last textfield return key type. Default is UIReturnKeyDefault.    */
    var lastTextFieldReturnKeyType = UIReturnKeyType.Default
    
    var textFieldInfoCache : NSMutableSet  = NSMutableSet()

    override init() {
        super.init()
    }
    
    /*! @method initWithViewController  */
    init(controller : UIViewController) {
        super.init()

        addRespondersFromView(controller.view)
    }

    private func textFieldCachedInfo(textField : UIView) -> Dictionary<String, AnyObject>? {

        for infoDict in textFieldInfoCache {

            if (infoDict[kIQTextField] as NSObject == textField) {
                return infoDict as? Dictionary<String, AnyObject>
            }
        }
        
        return nil
    }

    
    /*! @abstract Should pass UITextField/UITextView intance. Assign textFieldView delegate to self, change it's returnKeyType. */
    func addTextFieldView(view : UIView) {
        
        var dictInfo = NSMutableDictionary()
        
        dictInfo[kIQTextField] = view
        
        if (view.isKindOfClass(UITextField) == true)
        {
            var textField : UITextField = view as UITextField

            /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
            http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
            #if IQ_IS_XCODE_6_1_OR_GREATER
                dictInfo[kIQTextFieldReturnKeyType] = textField.returnKeyType.rawValue;
                #else
                dictInfo[kIQTextFieldReturnKeyType] = textField.returnKeyType.toRaw()
            #endif
            
            if textField.delegate != nil {
                dictInfo[kIQTextFieldDelegate] = textField.delegate
            }

            textField.delegate = self
        }
        else if (view.isKindOfClass(UITextView) == true)
        {
            var textView : UITextView = view as UITextView

            /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
            http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
            #if IQ_IS_XCODE_6_1_OR_GREATER
                dictInfo[kIQTextFieldReturnKeyType] = textView.returnKeyType.rawValue;
                #else
                dictInfo[kIQTextFieldReturnKeyType] = textView.returnKeyType.toRaw()
            #endif

            if textView.delegate != nil {
                dictInfo[kIQTextFieldDelegate] = textView.delegate
            }

            textView.delegate = self
        }

        textFieldInfoCache.addObject(dictInfo)
    }

    /*! @abstract Should pass UITextField/UITextView intance. Restore it's textFieldView delegate and it's returnKeyType. */
    func removeTextFieldView(view : UIView) {
        
        var dict : [String : AnyObject]? = textFieldCachedInfo(view)
        
        if (dict != nil)
        {
            var unwrappedDict = dict!
            
            if (view.isKindOfClass(UITextField) == true)
            {
                var textField : UITextField = view as UITextField
                
                /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_6_1_OR_GREATER
                    let returnKeyTypeValue = unwrappedDict[kIQTextFieldReturnKeyType] as NSNumber
                    textField.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                    #else
                    textField.returnKeyType = UIReturnKeyType.fromRaw((unwrappedDict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                #endif
                
                textField.delegate = unwrappedDict[kIQTextFieldDelegate] as UITextFieldDelegate?
            }
            else if (view.isKindOfClass(UITextView) == true)
            {
                var textView : UITextView = view as UITextView
                
                /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_6_1_OR_GREATER
                    let returnKeyTypeValue = unwrappedDict[kIQTextFieldReturnKeyType] as NSNumber
                    textView.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                    #else
                    textView.returnKeyType = UIReturnKeyType.fromRaw((unwrappedDict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                #endif

                textView.delegate = unwrappedDict[kIQTextFieldDelegate] as UITextViewDelegate?
            }
            
            textFieldInfoCache.removeObject(view)
        }

    }
    
    /*! @abstract Add all the UITextField/UITextView responderView's. */
    func addRespondersFromView(view : UIView) {
        
        var textFields = view.deepResponderViews()
        
        for textField in textFields as Array<UIView> {

            addTextFieldView(textField)
        }
    }
    
    /*! @abstract Remove all the UITextField/UITextView responderView's. */
    func removeRespondersFromView(view : UIView) {
        
        var textFields = view.deepResponderViews()
        
        for textField in textFields as Array<UIView> {
            
            removeTextFieldView(textField)
        }
    }
    
    func updateReturnKeyTypeOnTextField(view : UIView)
    {
        var tableView = view.superTableView()
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds, Otherwise fetching all the siblings.
        var textFields = (tableView != nil)   ?  tableView?.deepResponderViews()  :   view.responderSiblings()
        
        switch (toolbarManageBehaviour) {
            //If needs to sort it by tag
        case .ByTag:        textFields = textFields?.sortedArrayByTag()
            //If needs to sort it by Position
        case .ByPosition:   textFields = textFields?.sortedArrayByPosition()
        default:
            break
        }
        
        var lastView: UIView? = textFields?.lastObject as? UIView
        
        if (view.isKindOfClass(UITextField) == true)
        {
            var textField : UITextField = view as UITextField

            //If it's the last textField in responder view, else next
            textField.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.Next
        }
        else if (view.isKindOfClass(UITextView) == true)
        {
            var textView : UITextView = view as UITextView

            //If it's the last textField in responder view, else next
            textView.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.Next
        }

    }
    
    func goToNextResponderOrResign(view : UIView) {
        
        var tableView = view.superTableView()
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds, Otherwise fetching all the siblings.
        var textFields: NSArray! = (tableView != nil)   ?  tableView?.deepResponderViews()  :   view.responderSiblings()
        
        switch (toolbarManageBehaviour) {
            //If needs to sort it by tag
        case .ByTag:        textFields = textFields.sortedArrayByTag()
            //If needs to sort it by Position
        case .ByPosition:   textFields = textFields.sortedArrayByPosition()
        default:
            break
        }

        if (textFields.containsObject(view) == true)
        {
            //Getting index of current textField.
            var index = textFields.indexOfObject(view)
            
            //If it is not last textField. then it's next object becomeFirstResponder.
            if (index < (textFields.count - 1)) == true {
                
                var nextTextField = textFields[index+1] as UITextField
                
                //  Retaining textFieldView
                var  textFieldRetain = view
                
                var isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                
                //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                if (isAcceptAsFirstResponder == false)
                {
                    //If next field refuses to become first responder then restoring old textField as first responder.
                    textFieldRetain.becomeFirstResponder()
                    println("IQKeyboardManager: Refuses to become first responder: \(nextTextField)")
                }
            }
            else
            {
                //  Retaining textFieldView
                var  textFieldRetain = view
                
                var isResignAsFirstResponder = view.resignFirstResponder()
                //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                if (isResignAsFirstResponder == false)
                {
                    //If next field refuses to become first responder then restoring old textField as first responder.
                    textFieldRetain.becomeFirstResponder()
                    println("IQKeyboardManager: Refuses to become first responder: \(textFieldRetain)")
                }
            }
        }
    }
    
    deinit {
        
        for infoDict in textFieldInfoCache {
            
            var view : AnyObject = infoDict[kIQTextField]!!
            
            if (view.isKindOfClass(UITextField) == true)
            {
                var textField : UITextField = view as UITextField
                
                /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_6_1_OR_GREATER
                    let returnKeyTypeValue = infoDict[kIQTextFieldReturnKeyType] as NSNumber
                    textField.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                    #else
                    textField.returnKeyType = UIReturnKeyType.fromRaw((infoDict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                #endif
                
                textField.delegate = infoDict[kIQTextFieldDelegate] as UITextFieldDelegate?
            }
            else if (view.isKindOfClass(UITextView) == true)
            {
                var textView : UITextView = view as UITextView
                
                /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_6_1_OR_GREATER
                    let returnKeyTypeValue = infoDict[kIQTextFieldReturnKeyType] as NSNumber
                    textView.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                    #else
                    textView.returnKeyType = UIReturnKeyType.fromRaw((infoDict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                #endif

                textView.delegate = infoDict[kIQTextFieldDelegate] as UITextViewDelegate?
            }
        }
        
        textFieldInfoCache.removeAllObjects()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if((self.delegate?.respondsToSelector("textFieldShouldBeginEditing:")) != nil) {
            return (self.delegate?.textFieldShouldBeginEditing!(textField) == true)
        }
        else {
            return true
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if((self.delegate?.respondsToSelector("textFieldShouldEndEditing:")) != nil) {
            return (self.delegate?.textFieldShouldEndEditing!(textField) == true)
        }
        else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        updateReturnKeyTypeOnTextField(textField)
        
        self.delegate?.textFieldShouldBeginEditing!(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        self.delegate?.textFieldDidEndEditing!(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if((self.delegate?.respondsToSelector("textField:shouldChangeCharactersInRange:replacementString:")) != nil) {
            return (self.delegate?.textField!(textField, shouldChangeCharactersInRange: range, replacementString: string) == true)
        }
        else {
            return true
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        if((self.delegate?.respondsToSelector("textFieldShouldClear:")) != nil) {
            return (self.delegate?.textFieldShouldClear!(textField) == true)
        }
        else {
            return true
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        var shouldReturn = true
        
        if((self.delegate?.respondsToSelector("textFieldShouldReturn:")) != nil) {
            shouldReturn = (self.delegate?.textFieldShouldReturn!(textField) == true)
        }
        
        if (shouldReturn == true)
        {
            goToNextResponderOrResign(textField)
        }
        
        return shouldReturn
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if((self.delegate?.respondsToSelector("textViewShouldBeginEditing:")) != nil) {
            return (self.delegate?.textViewShouldBeginEditing!(textView) == true)
        }
        else {
            return true
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if((self.delegate?.respondsToSelector("textViewShouldEndEditing:")) != nil) {
            return (self.delegate?.textViewShouldEndEditing!(textView) == true)
        }
        else {
            return true
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        updateReturnKeyTypeOnTextField(textView)
        
        self.delegate?.textViewDidBeginEditing!(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        self.delegate?.textViewDidEndEditing!(textView)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        var shouldReturn = true
        
        if((self.delegate?.respondsToSelector("textView:shouldChangeCharactersInRange:replacementString:")) != nil) {
            shouldReturn = ((self.delegate?.textView!(textView, shouldChangeTextInRange: range, replacementText: text)) == true)
        }
        
        if (shouldReturn == true && text == "\n")
        {
            goToNextResponderOrResign(textView)
        }

        
        return shouldReturn
    }

    func textViewDidChange(textView: UITextView) {
        
        self.delegate?.textViewDidChange!(textView)
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        self.delegate?.textViewDidChangeSelection!(textView)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {

        if((self.delegate?.respondsToSelector("textView:shouldInteractWithURL:inRange:")) != nil) {
            return ((self.delegate?.textView!(textView, shouldInteractWithURL: URL, inRange: characterRange)) == true)
        }
        else {
            return true
        }

    }
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        
        if((self.delegate?.respondsToSelector("textView:shouldInteractWithTextAttachment:inRange:")) != nil) {
            return ((self.delegate?.textView!(textView, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange)) == true)
        }
        else {
            return true
        }
    }
}
