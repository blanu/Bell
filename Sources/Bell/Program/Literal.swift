//
//  Literal.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

public enum Literal
{
    case float(Double)
    case int(Int64)
}

extension Literal: CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
            case .float(let value):
                return value.description

            case .int(let value):
                return value.description
        }
    }
}
