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
    let object: Text
    let name: Text
    let arity: Int
    let modules: [ModuleInstance]
    let block: Block

    public init(object: Text, name: Text, arity: Int, modules: [ModuleInstance], block: Block)
    {
        self.object = object
        self.name = name
        self.arity = arity
        self.modules = modules
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

        switch self.arity
        {
            case 0:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String())\(uses) : \(self.block.description)"

            case 1:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x\(uses) : \(self.block.description)"

            case 2:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x y\(uses) : \(self.block.description)"

            case 3:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x y z\(uses) : \(self.block.description)"

            default:
                return "function with unsupported arity"
        }
    }
}
