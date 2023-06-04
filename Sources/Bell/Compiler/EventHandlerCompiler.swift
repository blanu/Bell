//
//  EventHandlerCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellCompiler
{
    public func generateHandlerText(_ handlerName: Text, _ eventName: Text, _ instances: [ModuleInstance]) -> String
    {
        if instances.isEmpty
        {
            return "    \(handlerName.toUTF8String()).\(eventName.toUTF8String())();"
        }
        else
        {
            return "    \(handlerName.toUTF8String()).\(eventName.toUTF8String())(\(instances.map { "&\($0.instanceName.toUTF8String())Universe" }.joined(separator: ", ")));"
        }
    }
}
