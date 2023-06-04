//
//  BellProgram.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation
import SwiftUI

public class BellProgram
{
    public var instances: [ModuleInstance] = []
    public var flows: [Flow] = []
    public var objects: [Object] = []

    public init()
    {
    }

    public init(instances: [ModuleInstance] = [], flows: [Flow] = [], objects: [Object] = [])
    {
        self.instances = instances
        self.flows = flows
        self.objects = objects
    }
}

extension BellProgram: CustomStringConvertible
{
    public var description: String
    {
        return """
        \(self.instances.map { $0.description }.joined(separator: "\n"))

        \(self.flows.map { $0.description }.joined(separator: "\n"))

        \(self.objects.map { $0.description }.joined(separator: "\n"))
        """
    }
}
