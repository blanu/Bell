//
//  Subject.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

public enum Subject
{
    case instance(ModuleInstance)
    case `self`(Object)
    case literal(Literal)
    case objectLocal(Text)
    case parameter(name: Text, type: Text)
}
