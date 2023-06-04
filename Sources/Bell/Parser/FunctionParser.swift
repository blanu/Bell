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
    public func findFunctions(_ object: Object, _ objectName: Text, _ instances: [ModuleInstance], _ source: Text) throws -> [Function]
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

            guard let (objectName, functionName, arity, modules) = try self.parseFunctionDefinition(instances, definitionText) else
            {
                return nil
            }

            guard let block = parseBlock(object, instances, blockText) else
            {
                return nil
            }

            return Function(object: objectName, name: functionName, arity: arity, modules: modules, block: block)
        }
    }

    public func parseFunctionDefinition(_ instances: [ModuleInstance], _ declaration: Text) throws -> (objectName: Text, functionName: Text, arity: Int, modules: [ModuleInstance])?
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

        return (objectName: objectName, functionName: eventName, arity: arity, modules: modules)
    }
}
