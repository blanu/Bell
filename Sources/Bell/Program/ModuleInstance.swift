//
//  ModuleInstance.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/4/23.
//

import Foundation

import Text

public class ModuleInstance
{
    public let module: Text
    public let instanceName: Text
    public let parameters: [Text]

    public init(module: Text, instanceName: Text, parameters: [Text])
    {
        self.module = module
        self.instanceName = instanceName
        self.parameters = parameters
    }
}

extension ModuleInstance: CustomStringConvertible
{
    public var description: String
    {
        return """
        instance \(self.instanceName.toUTF8String()) : \(self.module.toUTF8String()) \(self.parameters.map { $0.toUTF8String() }.joined(separator: " "))
        """
    }
}
