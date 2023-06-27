//
//  EventHandlerParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellParser
{
    public func findHandlers(_ namespace: Namespace, _ object: Object, _ objectName: Text, _ instances: [ModuleInstance], _ source: Text) throws -> [EventHandler]
    {
        let lines = source.split("\n").filter
        {
            line in

            return line.startsWith(Text(fromUTF8String: "event \(objectName.toUTF8String()) "))
        }

        let pairs = try lines.map
        {
            line in

            let goodLine = try line.dropPrefix("event ")

            return try goodLine.splitOn(" : ")
        }

        return try pairs.compactMap
        {
            (declaration: Text, blockText: Text) -> EventHandler? in

            guard let (objectName, eventName, argumentTypes, modules) = self.parseEventHandlerDeclaration(instances, declaration) else
            {
                return nil
            }

            guard let block = try parseBlock(namespace, object, instances, blockText) else
            {
                return nil
            }

            return EventHandler(objectName: objectName, eventName: eventName, argumentTypes: argumentTypes, modules: modules, block: block)
        }
    }

    public func parseEventHandlerDeclaration(_ instances: [ModuleInstance], _ declaration: Text) -> (objectName: Text, eventName: Text, argumentTypes: [Text], modules: [ModuleInstance])?
    {
        let declarationText: Text
        let modules: [ModuleInstance]
        if declaration.containsSubstring(" uses ")
        {
            let parts = declaration.split(" uses ")
            guard parts.count == 2 else
            {
                return nil
            }

            declarationText = parts[0]

            let moduleText = parts[1]
            let moduleParts = moduleText.split(" ")
            modules = moduleParts.compactMap
            {
                module in

                return instances.first
                {
                    instance in

                    instance.instanceName == module
                }
            }
        }
        else
        {
            declarationText = declaration
            modules = []
        }

        let parts: [Text] = declarationText.split(" ")

        guard parts.count >= 2 else
        {
            return nil
        }

        let objectName = parts[0]
        let eventName = parts[1]

        let rest = [Text](parts[2...])
        guard rest.count <= 3 else
        {
            return nil
        }

        var argumentTypes: [Text] = []
        if rest.count >= 1
        {
            if rest[0].startsWith("x:")
            {
                do
                {
                    argumentTypes.append(try rest[0].dropPrefix("x:"))
                }
                catch
                {
                    return nil
                }
            }
        }

        if rest.count >= 2
        {
            if rest[1].startsWith("y:")
            {
                do
                {
                    argumentTypes.append(try rest[1].dropPrefix("y:"))
                }
                catch
                {
                    return nil
                }
            }
        }

        if rest.count == 3
        {
            if rest[2].startsWith("z:")
            {
                do
                {
                    argumentTypes.append(try rest[2].dropPrefix("z:"))
                }
                catch
                {
                    return nil
                }
            }
        }

        return (objectName: objectName, eventName: eventName, argumentTypes: argumentTypes, modules: modules)
    }
}
