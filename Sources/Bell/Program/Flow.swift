//
//  Flow.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

import Text

public class Flow
{
    public var flows: [Text]

    public init(flows: [Text])
    {
        self.flows = flows
    }
}

extension Flow: Identifiable
{
}

extension Flow: CustomStringConvertible
{
    public var description: String
    {
        let flowsText = self.flows.map { $0.toUTF8String() }.joined(separator: " -> ")
        return "flow \(flowsText)"
    }
}
