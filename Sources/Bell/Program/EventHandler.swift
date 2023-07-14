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
    public let argumentTypes: [Text]
    public let returnType: Text?
    public let modules: [ModuleInstance]
    public let block: Block

    public init(objectName: Text, eventName: Text, argumentTypes: [Text], returnType: Text?, modules: [ModuleInstance], block: Block)
    {
        self.objectName = objectName
        self.eventName = eventName
        self.argumentTypes = argumentTypes
        self.returnType = returnType
        self.modules = modules
        self.block = block
    }
}

extension EventHandler: CustomStringConvertible
{
    public var description: String
    {
        let argumentsText: String
        if self.argumentTypes.isEmpty
        {
            argumentsText = ""
        }
        else
        {
            switch self.argumentTypes.count
            {
                case 1:
                    argumentsText = " x:\(self.argumentTypes[0])"

                case 2:
                    argumentsText = " x:\(self.argumentTypes[0]) y:\(self.argumentTypes[1])"

                case 3:
                    argumentsText = " x:\(self.argumentTypes[0]) y:\(self.argumentTypes[1]) z:\(self.argumentTypes[2])"

                default:
                    argumentsText = ""
            }
        }

        let modulesText: String
        if self.modules.isEmpty
        {
            modulesText = ""
        }
        else
        {
            modulesText = " uses \(self.modules.map { $0.instanceName.toUTF8String() }.joined(separator: " "))"
        }

        let returnTypeText: String
        if let returnType = self.returnType
        {
            returnTypeText = " -> \(returnType)"
        }
        else
        {
            returnTypeText = ""
        }

        return """
            event \(self.objectName.toUTF8String()) \(self.eventName.toUTF8String())\(argumentsText)\(returnTypeText)\(modulesText) : \(self.block.description)
            """
    }
}
