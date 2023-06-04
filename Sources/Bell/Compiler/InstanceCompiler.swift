//
//  InstanceCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellCompiler
{
    public func generateInstance(_ instance: ModuleInstance) -> String
    {
        let moduleName = instance.module.toUTF8String().replacingOccurrences(of: ":", with: "")
        let instanceName = instance.instanceName.toUTF8String()
        return """
        \(moduleName) \(instanceName);
        \(moduleName)Module \(instanceName)Module(&\(instanceName));
        \(moduleName)Universe \(instanceName)Universe(&\(instanceName)Module);
        """
    }
}
