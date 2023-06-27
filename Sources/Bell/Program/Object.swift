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
    public var properties: [Property]

    public init(name: Text, instances: [ModuleInstance], eventHandlers: [EventHandler], functions: [Function], properties: [Property] = [])
    {
        self.name = name
        self.instances = instances
        self.eventHandlers = eventHandlers
        self.functions = functions
        self.properties = properties
    }
}

extension Object: CustomStringConvertible
{
    public var description: String
    {
        return """
        object \(self.name.toUTF8String()) uses \(self.instances.map { $0.instanceName.toUTF8String() }.joined(separator: " "))
        \(self.eventHandlers.map { $0.description }.joined(separator: "\n"))
        \(self.functions.map { $0.description }.joined(separator: "\n"))
        \(self.properties.map { $0.description }.joined(separator: "\n"))
        """
    }
}
