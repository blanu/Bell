//
//  Chain.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/8/23.
//

import Foundation

public class Chain: Identifiable
{
    public var phrases: [Phrase]

    public init(phrases: [Phrase])
    {
        self.phrases = phrases
    }
}

extension Chain: CustomStringConvertible
{
    public var description: String
    {
        if phrases.count == 0
        {
            return ""
        }
        else if phrases.count == 1
        {
            return "\(phrases[0].description)"
        }
        else
        {
            return "\(phrases.map { $0.description }.joined(separator: " ; "))"
        }
    }
}
