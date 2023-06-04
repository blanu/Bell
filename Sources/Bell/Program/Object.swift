//
//  Object.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

import Text

public class Object
{
    public var name: Text
    public var instances: [ModuleInstance]
    public var eventHandlers: [EventHandler]
    public var functions: [Function]

    public init(name: Text, instances: [ModuleInstance], eventHandlers: [EventHandler], functions: [Function])
    {
        self.name = name
        self.instances = instances
        self.eventHandlers = eventHandlers
        self.functions = functions
    }
}

extension Object: CustomStringConvertible
{
    public var description: String
    {
        if instances.isEmpty
        {
            return """
            object \(self.name.toUTF8String())
            """
        }
        else
        {
            return """
            object \(self.name.toUTF8String()) uses \(self.instances.map { $0.instanceName.toUTF8String() }.joined(separator: " "))
            \(self.eventHandlers.map { $0.description }.joined(separator: "\n"))
            \(self.functions.map { $0.description }.joined(separator: "\n"))
            """
        }
    }
}
