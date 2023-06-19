//
//  Text+StringInterpolation.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/16/23.
//

import Foundation

import Text

extension String.StringInterpolation
{
    mutating func appendInterpolation(_ value: Text)
    {
        appendInterpolation("\(value.toUTF8String())")
    }
}
