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
    public func findObjects(_ instances: [ModuleInstance], _ text: Text) throws -> [Object]
    {
        var results: [Object] = []

        let declarations = try self.findObjectDeclarations(instances, text)

        for declaration in declarations
        {
            let (name, instances) = declaration
            let object = Object(name: name, instances: instances, eventHandlers: [], functions: [])
            let handlers = try self.findHandlers(object, declaration.name, instances, text)
            let functions = try self.findFunctions(object, declaration.name, instances, text)
            let properties = try self.findProperties(object, declaration.name, instances, text)
            object.eventHandlers = handlers
            object.functions = functions
            object.properties = properties
            results.append(object)
        }

        return results
    }

    public func findObjectDeclarations(_ instances: [ModuleInstance], _ text: Text) throws -> [(name: Text, modules: [ModuleInstance])]
    {
        let lines = text.split("\n")

        let goodLines = lines.filter
        {
            line in

            return line.startsWith("object ")
        }

        return try goodLines.compactMap
        {
            line in

            let goodLine = try line.dropPrefix("object ")
            if goodLine.containsSubstring(" uses ")
            {
                let sections = goodLine.split(" uses ")
                guard sections.count == 2 else
                {
                    return nil
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

                return (name, objectInstances)
            }
            else
            {
                let name = try goodLine.dropPrefix("object ")
                return (name, [])
            }
        }
    }
}
