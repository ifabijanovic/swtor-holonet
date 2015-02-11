//
//  ForumParser.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumParser {
    
    // MARK: - Properties
    
    private let numberFormatter: NSNumberFormatter
    
    // MARK: - Init
    
    init() {
        self.numberFormatter = NSNumberFormatter()
        self.numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        self.numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    }
    
    // MARK: - Public methods
    
    func linkParameter(#linkElement: HTMLElement?, name: String) -> String? {
        if let element = linkElement {
            if let href = element.objectForKeyedSubscript("href") as? String {
                if let value = NSURLComponents(string: href)?.queryValueForName(name) {
                    return value
                }
            }
        }
        return nil
    }
    
    func integerContent(#element: HTMLElement?) -> Int? {
        if element != nil {
            let text = element!.textContent.stripNewLinesAndTabs().stripSpaces()
            return self.numberFormatter.numberFromString(text)?.integerValue
        }
        return nil
    }
    
    func postDate(#element: HTMLElement?) -> String? {
        if element != nil {
            return element!.textContent.stripNewLinesAndTabs().formatPostDate()
        }
        return nil
    }
    
    func postNumber(#element: HTMLElement?) -> Int? {
        if element != nil {
            let text = element!.textContent!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces()
            if let range = text.rangeOfString("| #", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil) {
                var numberString = text.substringFromIndex(range.endIndex).stripNewLinesAndTabs().stripSpaces()
                if let spaceRange = numberString.rangeOfString("Next", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil) {
                    numberString = numberString.substringToIndex(spaceRange.startIndex)
                }
                return self.numberFormatter.numberFromString(numberString)?.integerValue
            }
        }
        return nil
    }
    
    func postText(#node: HTMLNode?) -> String? {
        if node != nil {
            return self.getText(node!)
        }
        return nil
    }
    
    // MARK: - Private methods
    
    private func getText(node: HTMLNode) -> String {
        // Leaf node
        if node.children.count == 0 {
            return node.textContent
        }
        
        // Special cases for quotes and spoilers
        if let element = node as? HTMLElement {
            var specialClass = ""
            if element.hasClass("quote") {
                specialClass = "quote"
            } else if element.hasClass("spoiler") {
                specialClass = "spoiler"
            }
            
            if specialClass.length > 0 {
                let header = element.firstNodeMatchingSelector(".\(specialClass)-header")?.textContent
                let body = element.firstNodeMatchingSelector(".\(specialClass)-body")?.textContent
                
                return self.formatBlock(header: header, body: body)
            }
        }
        
        // Continue down the DOM tree
        var text = ""
        node.children.enumerateObjectsUsingBlock { (child, index, stop) in
            if let childNode = child as? HTMLNode {
                text += self.getText(childNode)
            }
        }
        return text
    }
    
    private func formatBlock(#header: String?, body: String?) -> String {
        return "----------\n" + header!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces() + "\n\n" + body!.trimSpaces() + "\n----------\n\n"
    }
   
}
