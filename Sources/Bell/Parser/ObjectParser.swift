//
//  ObjectParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellParser
{
    public func findObjects(_ namespace: Namespace, _ instances: [ModuleInstance], _ text: Text) throws -> [Object]
    {
        var results: [Object] = []

        let declarations = try self.findObjectDeclarations(namespace, instances, text)

        for declaration in declarations
        {
            let (name, instances, parentType) = declaration

            namespace.add(name: name)

            let object = Object(name: name, parentType: parentType, instances: instances, eventHandlers: [], functions: [])

            let objectNamespace = prepopulateNamespace(namespace, name, instances, text)

            let properties = try self.findProperties(objectNamespace, object, name, instances, text)
            object.properties = properties

            let functions = try self.findFunctions(objectNamespace, object, name, instances, text)
            object.functions = functions

            let handlers = try self.findHandlers(objectNamespace, object, name, instances, text)
            object.eventHandlers = handlers

            results.append(object)
        }

        return results
    }

    public func prepopulateNamespace(_ oldNamespace: Namespace, _ object: Text, _ instances: [ModuleInstance], _ text: Text) -> Namespace
    {
        let namespace = Namespace(parent: oldNamespace)
        namespace.add(name: "this")
        for instance in instances
        {
            namespace.add(name: instance.instanceName)
        }

        let lines = text.split("\n")

        for line in lines
        {
            if line.startsWith(Text(fromUTF8String: "function \(object)"))
            {
                let parts = line.split((" "))
                guard parts.count >= 3 else
                {
                    continue
                }

                let name = parts[2]

                namespace.add(name: name)
            }

            if line.startsWith(Text(fromUTF8String: "property \(object)"))
            {
                let parts = line.split((" "))
                guard parts.count >= 3 else
                {
                    continue
                }

                let name = parts[2]

                namespace.add(name: name)
            }

            if line.startsWith(Text(fromUTF8String: "event \(object)"))
            {
                let parts = line.split((" "))
                guard parts.count >= 3 else
                {
                    continue
                }

                let name = parts[2]

                namespace.add(name: name)
            }
        }

        return namespace
    }

    public func findObjectDeclarations(_ namespace: Namespace, _ instances: [ModuleInstance], _ text: Text) throws -> [(name: Text, modules: [ModuleInstance], parentType: Text)]
    {
        let lines = text.split("\n")

        let goodLines = lines.filter
        {
            line in

            return line.startsWith("object ") || line.startsWith("effect ")
        }

        return try goodLines.compactMap
        {
            line in

            var goodLine: Text
            let parentType: Text
            if line.startsWith("effect ")
            {
                goodLine = try line.dropPrefix("effect ")
                let parts = goodLine.split(" : ")
                guard parts.count == 2 else
                {
                    throw ObjectParserError.effectRequiresParentType
                }

                goodLine = parts[0]
                parentType = parts[1]
            }
            else
            {
                goodLine = try line.dropPrefix("object ")
                parentType = "Object"
            }

            if goodLine.containsSubstring(" uses ")
            {
                let sections = goodLine.split(" uses ")
                guard sections.count == 2 else
                {
                    throw ObjectParserError.usesMissingModules
                }

                let name = sections[0]
                let objectInstances = sections[1].split(" ").compactMap
                {
                    objectInstance in

                    return instances.first
                    {
                        instance in

                        instance.instanceName == objectInstance
                    }
                }

                return (name, objectInstances, parentType)
            }
            else
            {
                return (goodLine, [], parentType)
            }
        }
    }
}

public enum ObjectParserError: Error
{
    case effectRequiresParentType
    case usesMissingModules
}
