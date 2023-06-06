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
    public func generateHandlerText(_ handlerName: Text, _ eventName: Text) -> String
    {
        return "    \(handlerName.toUTF8String()).\(eventName.toUTF8String())();"
    }
}
