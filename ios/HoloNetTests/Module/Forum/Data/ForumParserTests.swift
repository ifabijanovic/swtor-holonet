//
//  ForumParserTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 05/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import HTMLReader

class ForumParserTests: XCTestCase {
    fileprivate var parser: ForumParser!
    fileprivate var language: ForumLanguage!
    
    override func setUp() {
        super.setUp()
        
        self.parser = ForumParser()
        self.language = .english
    }
}

extension ForumParserTests {
    func testLinkParameter_Success() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test?param=value"])
        let param = self.parser!.linkParameter(linkElement: link, name: "param")!
        
        XCTAssertEqual(param, "value", "")
    }
    
    func testLinkParameter_ElementNil() {
        let param = self.parser!.linkParameter(linkElement: nil, name: "param")
        
        XCTAssertNil(param, "")
    }
    
    func testLinkParameter_NoParameters() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test"])
        let param = self.parser!.linkParameter(linkElement: link, name: "param")
        
        XCTAssertNil(param, "")
    }
    
    func testLinkParameter_MissingParameter() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test?param=value"])
        let param = self.parser!.linkParameter(linkElement: link, name: "otherParam")
        
        XCTAssertNil(param, "")
    }
    
    func testLinkParameter_MultipleParameters() {
        let link = HTMLElement(tagName: "a", attributes: ["href": "http://www.holonet.test?param1=value1&param2=value2"])
        let param = self.parser!.linkParameter(linkElement: link, name: "param1")!
        
        XCTAssertEqual(param, "value1", "")
    }
}

extension ForumParserTests {
    func testIntegerContent_Success() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "123"
        let value = self.parser!.integerContent(element: html)!
        
        XCTAssertEqual(value, 123, "")
    }
    
    func testIntegerContent_Nested() {
        let parent = HTMLElement(tagName: "div", attributes: nil)
        let child = HTMLElement(tagName: "div", attributes: nil)
        child.parentElement = parent
        child.textContent = "123"
        let value = self.parser!.integerContent(element: parent)!
        
        XCTAssertEqual(value, 123, "")
    }
    
    func testIntegerContent_ElementNil() {
        let value = self.parser!.integerContent(element: nil)
        
        XCTAssertNil(value, "")
    }
    
    func testIntegerContent_NoInteger() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "some text"
        let value = self.parser!.integerContent(element: html)
        
        XCTAssertNil(value, "")
    }
    
    func testIntegetContent_MixedContent() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "some text with 123 numbers 456"
        let value = self.parser!.integerContent(element: html)
        
        XCTAssertNil(value, "")
    }
}

extension ForumParserTests {
    func testPostDate_Success() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postDate(element: html)!
        
        XCTAssertEqual(value, "10.10.2014, 10:10 AM", "")
    }
    
    func testPostDate_Nested() {
        let parent = HTMLElement(tagName: "div", attributes: nil)
        let child = HTMLElement(tagName: "div", attributes: nil)
        child.parentElement = parent
        child.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postDate(element: parent)!
        
        XCTAssertEqual(value, "10.10.2014, 10:10 AM", "")
    }
    
    func testPostDate_ElementNil() {
        let value = self.parser!.postDate(element: nil)
        
        XCTAssertNil(value, "")
    }
}

extension ForumParserTests {
    func testPostNumber_Success() {
        let html = HTMLElement(tagName: "div", attributes: nil)
        html.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postNumber(element: html, language: self.language)!
        
        XCTAssertEqual(value, 1, "")
    }
    
    func testPostNumber_Nested() {
        let parent = HTMLElement(tagName: "div", attributes: nil)
        let child = HTMLElement(tagName: "div", attributes: nil)
        child.parentElement = parent
        child.textContent = "10.10.2014 , 10:10 AM | #1"
        let value = self.parser!.postNumber(element: parent, language: self.language)!
        
        XCTAssertEqual(value, 1, "")
    }
    
    func testPostNumber_ElementNil() {
        let value = self.parser!.postNumber(element: nil, language: self.language)
        
        XCTAssertNil(value, "")
    }
}

extension ForumParserTests {
    func testPostText_Success() {
        let header = "Header text"
        let body = "Body text"
        
        let value = self.parser!.formatPostBlock(header: header, body: body)
        
        XCTAssertEqual(value, String(format: self.parser!.postBlockFormat, header, body), "")
    }
    
    func testPostText_MissingHeader() {
        let body = "Body text"
        
        let value = self.parser!.formatPostBlock(header: nil, body: body)
        
        XCTAssertEqual(value, String(format: self.parser!.postBlockNoHeaderFormat, body), "")
    }
    
    func testPostText_MissingBody() {
        let header = "Header text"
        
        let value = self.parser!.formatPostBlock(header: header, body: nil)
        
        XCTAssertEqual(value, "", "")
    }
    
    func testPostText_Simple() {
        let html = "<div>Test post text<br>More text in new line</div>"
        let doc = HTMLDocument(string: html)
        
        let value = self.parser!.postText(node: doc.rootElement)
        
        XCTAssertNotNil(value, "")
        XCTAssertEqual(value!, doc.rootElement!.textContent, "")
    }
    
    func testPostText_Nested() {
        let html = "<div><span>Test post text</span><br><span>More text in new line</span><div>Even more text</div></div>"
        let doc = HTMLDocument(string: html)
        
        let value = self.parser!.postText(node: doc.rootElement)
        
        XCTAssertNotNil(value, "")
        XCTAssertEqual(value!, doc.rootElement!.textContent, "")
    }
    
    func testPostText_Styled() {
        let html = "<div><font color='Yellow'>Yellow text</font><font color='Red'><font size='4'><b>Red bold text of size 4</b></font></font><br><font size='6'><i>Italic text of size 6</i></font></div>"
        let doc = HTMLDocument(string: html)
        
        let value = self.parser!.postText(node: doc.rootElement)
        
        XCTAssertNotNil(value, "")
        XCTAssertEqual(value!, doc.rootElement!.textContent, "")
    }
    
    func testPostText_WithBlock() {
        for blockClass in self.parser!.postBlockClasses {
            let blockHtml = "<div class='\(blockClass)'><div class='\(blockClass)-header'>Block by TestUser</div><div class='\(blockClass)-body'>Block body text here<br>More text in new line</div></div>"
            let postHtml = "<div class='regular-post'>Regular post text<br><br>More regular post text in a new paragraph</div>"
            let html = "<div>\(blockHtml)\(postHtml)</div>"
            let doc = HTMLDocument(string: html)
            
            let value = self.parser!.postText(node: doc.rootElement)
            
            let header = doc.rootElement!.firstNode(matchingSelector: ".\(blockClass)-header")!.textContent
            let body = doc.rootElement!.firstNode(matchingSelector: ".\(blockClass)-body")!.textContent
            let block = self.parser!.formatPostBlock(header: header, body: body)
            let post = doc.rootElement!.firstNode(matchingSelector: ".regular-post")!.textContent
            
            XCTAssertNotNil(value, "")
            XCTAssertEqual(value!, "\(block)\(post)", "")
        }
    }
    
    func testPostText_WithMultipleBlocks() {
        for blockClass in self.parser!.postBlockClasses {
            let block1Html = "<div class='\(blockClass)'><div class='\(blockClass)-header'>Block by TestUser</div><div class='\(blockClass)-body'>Block body text here<br>More text in new line</div></div>"
            let block2Html = "<div class='\(blockClass)'><div class='\(blockClass)-header'>Block by DifferentUser</div><div class='\(blockClass)-body'>Simple block body</div></div>"
            
            let post1Html = "<div class='regular-post'>Regular post text<br><br>More regular post text in a new paragraph</div>"
            let post2Html = "<div class='regular-post'>Simple regular post text</div>"
            
            let html = "<div>\(block1Html)\(post1Html)\(block2Html)\(post2Html)</div>"
            let doc = HTMLDocument(string: html)
            
            let value = self.parser!.postText(node: doc.rootElement)
            
            let blocks = doc.rootElement!.nodes(matchingSelector: ".\(blockClass)")
            var blocksText = Array<String>()
            for block in blocks {
                let header = block.firstNode(matchingSelector: ".\(blockClass)-header")!.textContent
                let body = block.firstNode(matchingSelector: ".\(blockClass)-body")!.textContent
                let block = self.parser!.formatPostBlock(header: header, body: body)
                blocksText.append(block)
            }
            let posts = doc.rootElement!.nodes(matchingSelector: ".regular-post")
            var postsText = Array<String>()
            for post in posts {
                postsText.append(post.textContent)
            }
            
            XCTAssertNotNil(value, "")
            XCTAssertEqual(value!, "\(blocksText[0])\(postsText[0])\(blocksText[1])\(postsText[1])", "")
        }
    }
    
    func testPostText_WithSpecialBlock() {
        let blockHtml = "<div style='margin:20px; margin-top:5px; '><div class='smallfont'>Quote:</div><table><tbody><tr><td class='alt2'><div class='header'>Block by TestUser</div><div class='body'>Block body text here<br>More text in new line</div></td></tr></tbody></table></div>"
        let postHtml = "<div class='regular-post'>Regular post text<br><br>More regular post text in a new paragraph</div>"
        
        let html = "<div>\(blockHtml)\(postHtml)</div>"
        let doc = HTMLDocument(string: html)
        
        let value = self.parser!.postText(node: doc.rootElement)
        
        let header = doc.rootElement!.firstNode(matchingSelector: ".header")!.textContent
        let body = doc.rootElement!.firstNode(matchingSelector: ".body")!.textContent
        let block = self.parser!.formatPostBlock(header: header, body: body)
        let post = doc.rootElement!.firstNode(matchingSelector: ".regular-post")!.textContent
        
        XCTAssertNotNil(value, "")
        XCTAssertEqual(value!, "\(block)\(post)", "")
    }
}
