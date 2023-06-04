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

    public init(module: Text, instanceName: Text)
    {
        self.module = module
        self.instanceName = instanceName
    }
}

extension ModuleInstance: CustomStringConvertible
{
    public var description: String
    {
        return """
        instance \(instanceName.toUTF8String()) : \(module.toUTF8String())
        """
    }
}
