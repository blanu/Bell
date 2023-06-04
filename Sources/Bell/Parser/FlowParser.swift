//
//  EventParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellParser
{
    public func findFlows(_ instances: [ModuleInstance], _ source: Text) throws -> [Flow]
    {
        let lines = source.split("\n").filter
        {
            line in

            return line.startsWith("flow ")
        }

        return try lines.map
        {
            line in

            let goodLine = try line.dropPrefix("flow ")

            return Flow(flows: goodLine.split(" -> ").map { $0.trim() })
        }
    }
}
