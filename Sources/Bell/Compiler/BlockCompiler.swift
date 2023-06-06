//
//  BlockCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellCompiler
{
    public func generateSentence(_ sentence: Sentence) -> String
    {
        switch sentence.subject
        {
            case .instance(let instance):
                if sentence.chains.count == 0
                {
                    return ""
                }
                else if sentence.chains.count == 1
                {
                    return self.generatePhrases(instance.instanceName.toUTF8String(), sentence.chains[0].phrases)
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return self.generateOnlyChains(instance.instanceName.toUTF8String(), sentence.chains)
                }
                else
                {
                    return self.generateChainsAndPhrases(instance.instanceName.toUTF8String(), sentence.chains)
                }

            case .`self`(_):
                if sentence.chains.count == 0
                {
                    return ""
                }
                else if sentence.chains.count == 1
                {
                    return self.generatePhrases("this", sentence.chains[0].phrases)
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return self.generateOnlyChains("this", sentence.chains)
                }
                else
                {
                    return self.generateChainsAndPhrases("this", sentence.chains)
                }
        }
    }

    public func generateOnlyChains(_ instanceName: String, _ chains: [Chain]) -> String
    {
        if instanceName == "this"
        {
            return "    \(chains.map { self.generateChain(instanceName, $0) }.joined(separator: "."));\n"
        }
        else
        {
            return "    \(instanceName)->\(chains.map { self.generateChain(instanceName, $0) }.joined(separator: "."));\n"
        }
    }

    public func generateChain(_ instanceName: String, _ chain: Chain) -> String
    {
        return chain.phrases.map { self.generatePhrase(instanceName, $0) }.joined(separator: "\n")
    }

    public func generatePhrase(_ phrase: Phrase) -> String
    {
        return "\(phrase.verb.name.toUTF8String())(\(self.generateArguments(phrase.arguments)));"
    }

    public func generatePhrases(_ instanceName: String, _ phrases: [Phrase]) -> String
    {
        if phrases.count == 0
        {
            return ""
        }
        else if phrases.count == 1
        {
            return self.generatePhrase(instanceName, phrases[0])
        }
        else
        {
            return phrases.map { self.generatePhrase(instanceName, $0) }.joined(separator: "\n")
        }
    }

    public func generatePhrase(_ instanceName: String, _ phrase: Phrase) -> String
    {
        if instanceName == "this"
        {
            return "    \(phrase.verb.name.toUTF8String())(\(self.generateArguments(phrase.arguments)));"
        }
        else
        {
            return "    \(instanceName)->\(phrase.verb.name.toUTF8String())(\(self.generateArguments(phrase.arguments)));"
        }
    }

    public func generateChainsAndPhrases(_ instanceName: String, _ chains: [Chain]) -> String
    {
        return "" // FIXME
    }


    public func generateArguments(_ arguments: [Argument]) -> String
    {
        if arguments.count == 0
        {
            return ""
        }
        else if arguments.count == 1
        {
            return self.generateArgument(arguments[0])
        }
        else
        {
            return arguments.map { self.generateArgument($0) }.joined(separator: ", ")
        }
    }

    public func generateArgument(_ argument: Argument) -> String
    {
        switch argument
        {
            case .name(let value):
                return value.toUTF8String()

            case .literal(let literal):
                switch literal
                {
                    case .float(let value):
                        return "\(value)"

                    case .int(let value):
                        return "\(value)"
                }
        }
    }
}
