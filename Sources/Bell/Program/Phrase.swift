//
//  Phrase.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/5/23.
//

import Foundation

public class Phrase: Identifiable
{
    public var verb: Verb
    public var arguments: [Argument]

    public init(verb: Verb, arguments: [Argument])
    {
        self.verb = verb
        self.arguments = arguments
    }
}

extension Phrase: CustomStringConvertible
{
    public var description: String
    {
        if self.arguments.count == 0
        {
        return """
        \(verb.name.toUTF8String())
        """
        }
        else
        {
        return """
        \(verb.name.toUTF8String()) \(arguments.map { $0.description }.joined(separator: " "))
        """
        }
    }
}

