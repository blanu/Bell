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
    var argumentTypes: [Text]
    var modules: [ModuleInstance]
    var returnType: Type
    var block: Block

    public init(object: Text, name: Text, argumentTypes: [Text], modules: [ModuleInstance], returnType: Type, block: Block)
    {
        self.object = object
        self.name = name
        self.argumentTypes = argumentTypes
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
            returnType = " -> \(self.returnType.rawValue)"
        }

        switch self.argumentTypes.count
        {
            case 0:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String())\(uses)\(returnType) : \(self.block.description)"

            case 1:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x:\(self.argumentTypes[0])\(uses)\(returnType) : \(self.block.description)"

            case 2:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x:\(self.argumentTypes[0]) y:\(self.argumentTypes[1])\(uses)\(returnType) : \(self.block.description)"

            case 3:
                return "function \(self.object.toUTF8String()) \(self.name.toUTF8String()) x\(self.argumentTypes[0]) y\(self.argumentTypes[1]) z\(self.argumentTypes[2])\(uses)\(returnType) : \(self.block.description)"

            default:
                return "function with unsupported arity"
        }
    }
}
