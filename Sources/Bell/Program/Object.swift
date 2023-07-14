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
    public var parentType: Text
    public var instances: [ModuleInstance]
    public var eventHandlers: [EventHandler]
    public var functions: [Function]
    public var properties: [Property]

    public init(name: Text, parentType: Text, instances: [ModuleInstance], eventHandlers: [EventHandler], functions: [Function], properties: [Property] = [])
    {
        self.name = name
        self.parentType = parentType
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
        let objectKeyword: String
        let parentTypeText: String
        if self.parentType == "Object"
        {
            objectKeyword = "object"
            parentTypeText = ""
        }
        else
        {
            objectKeyword = "effect"
            parentTypeText = " : \(self.parentType)"
        }

        let instanceText: String
        if self.instances.isEmpty
        {
            instanceText = ""
        }
        else
        {
            instanceText = " uses \(self.instances.map { $0.instanceName.toUTF8String() }.joined(separator: " "))"
        }

        return """
        \(objectKeyword) \(self.name)\(instanceText)\(parentTypeText)
        \(self.eventHandlers.map { $0.description }.joined(separator: "\n"))
        \(self.functions.map { $0.description }.joined(separator: "\n"))
        \(self.properties.map { $0.description }.joined(separator: "\n"))
        """
    }
}

extension Object
{
    public func getSubjectType(_ subject: Subject) -> String
    {
        switch subject
        {
            case .`self`(let value):
                return value.name.toUTF8String()

            case .instance(let value):
                return value.module.toUTF8String()

            case .literal(let value):
                switch value
                {
                    case .float(_):
                        return "float"

                    case .int(_):
                        return "int"
                }

            case .objectLocal(let name):
                if self.properties.contains(where: { $0.name == name })
                {
                    return "int"
                }
                else if let function = self.functions.first(where: { $0.name == name })
                {
                    return function.returnType.rawValue
                }

            case .parameter(name: _, type: let type):
                return type.toUTF8String()
        }

        return "FAILED"
    }
}
