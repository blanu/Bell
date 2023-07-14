//
//  FunctionParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellParser
{
    public func findFunctions(_ namespace: Namespace, _ object: Object, _ objectName: Text, _ instances: [ModuleInstance], _ source: Text) throws -> [Function]
    {
        let lines = source.split("\n").filter
        {
            line in

            return line.startsWith(Text(fromUTF8String: "function \(objectName.toUTF8String())"))
        }

        let pairs = try lines.map
        {
            line in

            let goodLine = try line.dropPrefix("function ")

            return try goodLine.splitOn(" : ")
        }

        return try pairs.compactMap
        {
            (definitionText: Text, blockText: Text) -> Function? in

            guard let (objectName, functionName, argumentTypes, modules, returnType) = try self.parseFunctionDefinition(namespace, instances, definitionText) else
            {
                return nil
            }

            guard let block = try parseBlock(namespace, object, argumentTypes, instances, blockText) else
            {
                return nil
            }

            return Function(object: objectName, name: functionName, argumentTypes: argumentTypes, modules: modules, returnType: returnType, block: block)
        }
    }

    public func parseFunctionDefinition(_ namespace: Namespace, _ instances: [ModuleInstance], _ declaration: Text) throws -> (objectName: Text, functionName: Text, argumentTypes: [Text], modules: [ModuleInstance], returnType: Type)?
    {
        var declarationText: Text = declaration

        let returnType: Type
        if declarationText.containsSubstring(" -> ")
        {
            let parts = declarationText.split(" -> ")
            guard parts.count == 2 else
            {
                return nil
            }

            guard let type = Type(rawValue: parts[1].toUTF8String()) else
            {
                return nil
            }

            returnType = type
            declarationText = parts[0]
        }
        else
        {
            returnType = .void
        }

        let modules: [ModuleInstance]
        if declarationText.containsSubstring(" uses ")
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

        return (objectName: objectName, functionName: eventName, argumentTypes: argumentTypes, modules: modules, returnType: returnType)
    }
}
