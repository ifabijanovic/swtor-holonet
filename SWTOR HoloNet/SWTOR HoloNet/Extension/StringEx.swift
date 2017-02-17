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
        let withoutNewLines = self.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
        let withoutTabs = withoutNewLines.replacingOccurrences(of: "\t", with: "", options: .literal, range: nil)
        return withoutTabs
    }

    func trimSpaces() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func stripSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    func collapseMultipleSpaces() -> String {
        return self.replacingOccurrences(of: "[ ]+", with: " ", options: .regularExpression, range: nil)
    }
    
    func formatPostDate() -> String {
        var value = self.collapseMultipleSpaces()
        if let range = value.range(of: "| #", options: .literal, range: nil, locale: nil) {
            value = value.substring(to: range.lowerBound)
        }
        value = value.replacingOccurrences(of: " ,", with: ",", options: .literal, range: nil)
        return value.trimSpaces()
    }
   
}
