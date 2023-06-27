//
//  Namespace.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/26/23.
//

import Foundation

import Text

public class Namespace
{
    public let parent: Namespace?
    public var names: Set<Text>

    public init()
    {
        self.parent = nil
        names = Set<Text>()
    }

    public init(parent: Namespace)
    {
        self.parent = parent
        names = Set<Text>()
    }

    public func add(name: Text)
    {
        self.names.insert(name)
    }

    public func contains(name: Text) -> Bool
    {
        if self.names.contains(name)
        {
            return true
        }
        else
        {
            if let parent = self.parent
            {
                return parent.contains(name: name)
            }
            else
            {
                return false
            }
        }
    }
}
