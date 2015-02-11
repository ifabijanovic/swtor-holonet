//
//  ForumParser.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumParser {
    
    // MARK: - Constants
    
    let postBlockFormat = "----------\n%@\n\n%@\n----------\n\n"
    let postBlockNoHeaderFormat = "----------\n%@\n----------\n\n"
    let postBlockClasses = ["quote", "spoiler"]
    
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
    
    func formatPostBlock(#header: String?, body: String?) -> String {
        if body == nil { return "" }
        return header != nil
            ? String(format: self.postBlockFormat, header!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces(), body!.trimSpaces())
            : String(format: self.postBlockNoHeaderFormat, body!.trimSpaces())
    }
    
    func postText(#node: HTMLNode?) -> String? {
        if node != nil {
            return self.getPostText(node!)
        }
        return nil
    }
    
    // MARK: - Private methods
    
    private func getPostText(node: HTMLNode) -> String {
        // Leaf node
        if node.children.count == 0 {
            return node.textContent
        }
        
        if let element = node as? HTMLElement {
            // Special formatting for "blocks" inside posts
            for blockClass in self.postBlockClasses {
                if element.hasClass(blockClass) {
                    let header = element.firstNodeMatchingSelector(".\(blockClass)-header")?.textContent
                    let body = element.firstNodeMatchingSelector(".\(blockClass)-body")?.textContent
                    
                    return self.formatPostBlock(header: header, body: body)
                }
            }
        }
        
        // Continue down the DOM tree
        var text = ""
        node.children.enumerateObjectsUsingBlock { (child, index, stop) in
            if let childNode = child as? HTMLNode {
                text += self.getPostText(childNode)
            }
        }
        return text
    }
    
}
