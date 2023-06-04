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
    public func findModuleInstances(_ source: Text) throws -> [ModuleInstance]
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

        let goodParts = parts.filter
        {
            parts in

            return parts.count == 2 && !parts[1].containsSubstring(" ")
        }

        let pairs = goodParts.compactMap
        {
            parts in

            let left = parts[0]
            let right = parts[1]

            return (left, right)
        }

        let results = pairs.compactMap
        {
            (instanceName, moduleName) in

            return ModuleInstance(module: moduleName, instanceName: instanceName)
        }

        return results
    }

}
