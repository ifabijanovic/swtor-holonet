//
//  String.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

extension String {

    // MARK: - Cleanup
    
    func stripNewLinesAndTabs() -> String {
        let withoutNewLines = self.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let withoutTabs = withoutNewLines.stringByReplacingOccurrencesOfString("\t", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return withoutTabs
    }
    
    func stripSpaces() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func formatPostDate() -> String {
        let withoutSpaces = self.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        if let range = withoutSpaces.rangeOfString("|#", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil) {
            let withoutPostNumber = withoutSpaces.substringToIndex(range.startIndex)
            return withoutPostNumber
        }
        return withoutSpaces
    }
    
    // MARK: - Substring
    
    func substringToIndex(index: Int) -> String {
        return self.substringToIndex(advance(self.startIndex, index))
    }
    
    func substringFromIndex(index: Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    
    func substringWithRange(range: Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self.substringWithRange(start..<end)
    }
   
}
