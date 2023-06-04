//
//  EventHandler.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

import Text

public class EventHandler: Identifiable
{
    public let objectName: Text
    public let eventName: Text
    public let modules: [ModuleInstance]
    public let block: Block

    public init(objectName: Text, eventName: Text, modules: [ModuleInstance], block: Block)
    {
        self.objectName = objectName
        self.eventName = eventName
        self.modules = modules
        self.block = block
    }
}

extension EventHandler: CustomStringConvertible
{
    public var description: String
    {
        if self.modules.isEmpty
        {
            return """
            event \(self.objectName.toUTF8String()) \(self.eventName.toUTF8String()) : \(self.block.description)
            """
        }
        else
        {
            let modules = self.modules.map { $0.instanceName.toUTF8String() }.joined(separator: " ")

            return """
            event \(self.objectName.toUTF8String()) \(self.eventName.toUTF8String()) uses \(modules) : \(self.block.description)
            """
        }
    }
}
