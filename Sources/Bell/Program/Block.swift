//
//  Block.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

public class Block
{
    public var sentences: [Sentence] = []

    public init()
    {
    }

    public init(_ sentences: [Sentence])
    {
        self.sentences = sentences
    }
}

extension Block: CustomStringConvertible
{
    public var description: String
    {
        if self.sentences.count == 0
        {
            return ""
        }
        else if self.sentences.count == 1
        {
            return self.sentences[0].description
        }
        else
        {
            return self.sentences.map { $0.description }.joined(separator: " . ")
        }
    }
}
