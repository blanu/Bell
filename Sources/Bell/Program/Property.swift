//
//  Property.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/17/23.
//

import Foundation

import Text

public class Property
{
    public let object: Text
    public let name: Text
    public let moduleName: Text
    public let parameters: [Text]

    public init(object: Text, name: Text, moduleName: Text, parameters: [Text])
    {
        self.object = object
        self.name = name
        self.moduleName = moduleName
        self.parameters = parameters
    }
}

extension Property: CustomStringConvertible
{
    public var description: String
    {
        return "property \(self.object) \(self.name) : \(self.moduleName) \(self.parameters.map { $0.toUTF8String() }.joined(separator: " "))"
    }
}
