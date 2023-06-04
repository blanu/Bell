//
//  Argument.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

import Text

public enum Argument
{
    case name(Text)
    case literal(Literal)
}

extension Argument: CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
            case .name(let value):
                return value.toUTF8String()
                
            case .literal(let value):
                return value.description
        }
    }
}
