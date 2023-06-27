//
//  InstanceParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellParser
{
    public func findModuleInstances(_ namespace: Namespace, _ source: Text) throws -> [ModuleInstance]
    {
        let lines = source.split("\n").filter
        {
            line in

            return line.startsWith("instance ")
        }

        let parts = try lines.map
        {
            line in

            let goodLine = try line.dropPrefix("instance ")

            return goodLine.split(" : ")
        }

        let pairs = parts.compactMap
        {
            parts in

            let left = parts[0]
            let right = parts[1]

            return (left, right)
        }

        let results = pairs.compactMap
        {
            (instanceName, rest) in

            namespace.add(name: instanceName)

            if rest.containsSubstring(" ")
            {
                let parts = rest.split(" ")
                let moduleName = parts[0]
                let parameters = [Text](parts[1...])
                return ModuleInstance(module: moduleName, instanceName: instanceName, parameters: parameters)
            }
            else
            {
                let moduleName = rest
                return ModuleInstance(module: moduleName, instanceName: instanceName, parameters: [])
            }
        }

        return results
    }

}
