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
    public func findHandlers(_ object: Object, _ objectName: Text, _ instances: [ModuleInstance], _ source: Text) throws -> [EventHandler]
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

        return pairs.compactMap
        {
            (declaration: Text, blockText: Text) -> EventHandler? in

            guard let (objectName, eventName, modules) = self.parseEventHandlerDeclaration(instances, declaration) else
            {
                return nil
            }

            guard let block = parseBlock(object, instances, blockText) else
            {
                return nil
            }

            return EventHandler(objectName: objectName, eventName: eventName, modules: modules, block: block)
        }
    }

    public func parseEventHandlerDeclaration(_ instances: [ModuleInstance], _ declaration: Text) -> (objectName: Text, eventName: Text, modules: [ModuleInstance])?
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

        return (objectName: objectName, eventName: eventName, modules: modules)
    }
}
