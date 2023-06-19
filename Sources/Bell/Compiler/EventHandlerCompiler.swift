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
    public func generateHandlerText(_ handlerName: Text, _ eventName: Text, argumentCount: Int) -> String
    {
        let argumentList: String
        switch argumentCount
        {
            case 0:
                argumentList = ""

            case 1:
                argumentList = "x"

            case 2:
                argumentList = "x, y"

            case 3:
                argumentList = "x, y, z"

            default:
                return ""
        }

        return "  \(handlerName.toUTF8String()).\(eventName.toUTF8String())(\(argumentList));"
    }
}
