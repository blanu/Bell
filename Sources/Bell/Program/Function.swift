//
//  Function.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/31/23.
//

import Foundation

import Text

public class Function
{
    var object: Text
    var name: Text
    var arity: Int
    var modules: [ModuleInstance]
    var returnType: Type
    var block: Block

    public init(object: Text, name: Text, arity: Int, modules: [ModuleInstance], returnType: Type, block: Block)
    {
        self.object = object
        self.name = name
        self.arity = arity
        self.modules = modules
        self.returnType = returnType
        self.block = block
    }
}

extension Function: CustomStringConvertible
{
    public var description: String
    {
        let uses: String
        if self.modules.isEmpty
        {
            uses = ""
        }
        else
        {
            uses = " uses \(self.modules.map { $0.instanceName.toUTF8String() }.joined(separator: " "))"
        }

        let returnType: String
        if self.returnType == .void
        {
            returnType = ""
        }
        else
        {
            returnType = " \(self.returnType.rawValue)"
        }

        switch self.arity
        {
            case 0:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String())\(uses)\(returnType) : \(self.block.description)"

            case 1:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x\(uses)\(returnType) : \(self.block.description)"

            case 2:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x y\(uses)\(returnType) : \(self.block.description)"

            case 3:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x y z\(uses)\(returnType) : \(self.block.description)"

            default:
                return "function with unsupported arity"
        }
    }
}
