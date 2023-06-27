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

            guard let (objectName, functionName, arity, modules, returnType) = try self.parseFunctionDefinition(namespace, instances, definitionText) else
            {
                return nil
            }

            guard let block = try parseBlock(namespace, object, instances, blockText) else
            {
                return nil
            }

            return Function(object: objectName, name: functionName, arity: arity, modules: modules, returnType: returnType, block: block)
        }
    }

    public func parseFunctionDefinition(_ namespace: Namespace, _ instances: [ModuleInstance], _ declaration: Text) throws -> (objectName: Text, functionName: Text, arity: Int, modules: [ModuleInstance], returnType: Type)?
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

        let rest = parts[2...]
        var arity: Int = 0
        if (rest.count >= 1) && (rest[0] == "x")
        {
            arity = 1
            
            if (rest.count >= 2) && (rest[1] == "y")
            {
                arity = 2
                
                if (rest.count >= 3) && (rest[2] == "z")
                {
                    arity = 3
                    
                    if rest.count >= 4
                    {
                        print("unsupported arity \(rest.count)")
                        return nil
                    }
                }
            }
        }

        return (objectName: objectName, functionName: eventName, arity: arity, modules: modules, returnType: returnType)
    }
}
