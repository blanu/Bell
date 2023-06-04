//
//  Sentence.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

public class Sentence: Identifiable
{
    public var subject: Subject
    public var chains: [Chain]

    public init(subject: Subject, chains: [Chain])
    {
        self.subject = subject
        self.chains = chains
    }
}

extension Sentence: CustomStringConvertible
{
    public var description: String
    {
        switch self.subject
        {
            case .instance(let instance):
                if chains.count == 0
                {
                    return "\(instance.instanceName.toUTF8String())"
                }
                else if chains.count == 1
                {
                    return "\(instance.instanceName.toUTF8String()) \(chains[0].description)"
                }
                else
                {
                    return "\(instance.instanceName.toUTF8String()) " + (chains.map { $0.description }.joined(separator: " | "))
                }

            case .`self`(_):
                if chains.count == 0
                {
                    return "self"
                }
                else if chains.count == 1
                {
                    return "self \(chains[0].description)"
                }
                else
                {
                    return "self " + (chains.map { $0.description }.joined(separator: " | "))
                }
        }
    }
}
