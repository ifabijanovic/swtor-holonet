//
//  ForumParser.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import HTMLReader

class ForumParser {
    
    // MARK: - Constants
    
    let postBlockFormat = "----------\n%@\n\n%@\n----------\n\n"
    let postBlockNoHeaderFormat = "----------\n%@\n----------\n\n"
    let postBlockClasses = ["quote", "spoiler"]
    
    // MARK: - Properties
    
    private let numberFormatter: NumberFormatter
    
    // MARK: - Init
    
    init() {
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        self.numberFormatter.numberStyle = .decimal
    }
    
    // MARK: - Public methods
    
    func linkParameter(linkElement: HTMLElement?, name: String) -> String? {
        guard let href = linkElement?["href"],
            let value = URLComponents(string: href)?.queryValueForName(name)
            else { return nil }
        
        return value
    }
    
    func integerContent(element: HTMLElement?) -> Int? {
        guard let text = element?.textContent.stripNewLinesAndTabs().stripSpaces() else { return nil }
        return self.numberFormatter.number(from: text)?.intValue
    }
    
    func postDate(element: HTMLElement?) -> String? {
        return element?.textContent.stripNewLinesAndTabs().formatPostDate()
    }
    
    func postNumber(element: HTMLElement?) -> Int? {
        guard let text = element?.textContent.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces(),
            let range = text.range(of: "| #", options: .literal, range: nil, locale: nil)
            else { return nil }
        
        var numberString = text.substring(from: range.upperBound).stripNewLinesAndTabs().stripSpaces()
        if let spaceRange = numberString.range(of: "Next", options: .literal, range: nil, locale: nil) {
            numberString = numberString.substring(to: spaceRange.lowerBound)
        }
        return self.numberFormatter.number(from: numberString)?.intValue
    }
    
    func formatPostBlock(header: String?, body: String?) -> String {
        if body == nil { return "" }
        return header != nil
            ? String(format: self.postBlockFormat, header!.stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces(), body!.trimSpaces())
            : String(format: self.postBlockNoHeaderFormat, body!.trimSpaces())
    }
    
    func postText(node: HTMLNode?) -> String? {
        if node != nil {
            return self.getPostText(node!)
        }
        return nil
    }
    
    // MARK: - Private methods
    
    private func getPostText(_ node: HTMLNode) -> String {
        // Leaf node
        if node.children.count == 0 {
            return node.textContent
        }
        
        if let element = node as? HTMLElement {
            // Special formatting for "blocks" inside posts
            for blockClass in self.postBlockClasses {
                if element.hasClass(blockClass) {
                    let header = element.firstNode(matchingSelector: ".\(blockClass)-header")?.textContent
                    let body = element.firstNode(matchingSelector: ".\(blockClass)-body")?.textContent
                    
                    return self.formatPostBlock(header: header, body: body)
                }
            }
            
            // Special formatting for a weird quote block sometimes found on DevTracker
            if element.hasAttribute(name: "style", containingValue: "margin:20px") {
                if let quoteElement = element.firstNode(matchingSelector: ".alt2") {
                    let nodes = quoteElement.nodes(matchingSelector: "div")
                    if nodes.count > 1 {
                        let header = nodes[0].textContent
                        let body = nodes[1].textContent
                        
                        return self.formatPostBlock(header: header, body: body)
                    }
                }
            }
        }
        
        // Continue down the DOM tree
        var text = ""
        node.children.enumerateObjects({ (child, index, stop) in
            if let childNode = child as? HTMLNode {
                text += self.getPostText(childNode)
            }
        })
        return text
    }
    
}
