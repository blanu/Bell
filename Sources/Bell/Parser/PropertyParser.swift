//
//  PropertyParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/19/23.
//

import Foundation

import Text

extension BellParser
{
    public func findProperties(_ object: Object, _ objectName: Text, _ instances: [ModuleInstance], _ source: Text) throws -> [Property]
    {
        let lines = source.split("\n").filter
        {
            line in

            return line.startsWith(Text(fromUTF8String: "property \(objectName.toUTF8String())"))
        }

        let pairs = try lines.map
        {
            line in

            let goodLine = try line.dropPrefix("property ")

            return try goodLine.splitOn(" : ")
        }

        return try pairs.compactMap
        {
            (definitionText: Text, blockText: Text) -> Property? in

            guard let (objectName, propertyName) = try parsePropertyDeclaration(definitionText) else
            {
                return nil
            }

            guard let (moduleName, parameters) = try parsePropertyDefinition(blockText) else
            {
                return nil
            }

            return Property(object: objectName, name: propertyName, moduleName: moduleName, parameters: parameters)
        }
    }

    public func parsePropertyDeclaration(_ declaration: Text) throws -> (objectName: Text, propertyName: Text)?
    {
        let parts: [Text] = declaration.split(" ")

        guard parts.count == 2 else
        {
            return nil
        }

        let objectName = parts[0]
        let propertyName = parts[1]

        return (objectName: objectName, propertyName: propertyName)
    }

    public func parsePropertyDefinition(_ definition: Text) throws -> (moduleName: Text, parameters: [Text])?
    {
        let parts = definition.split(" ")
        guard parts.count >= 1 else
        {
            return nil
        }

        let moduleName = parts[0]
        if parts.count == 1
        {
            return (moduleName: moduleName, parameters: [])
        }
        else
        {
            let rest = [Text](parts[1...])

            return (moduleName: moduleName, parameters: rest)
        }
    }
}
