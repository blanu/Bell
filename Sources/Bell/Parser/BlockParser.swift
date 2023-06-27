//
//  BlockParser.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellParser
{
    func parseBlock(_ namespace: Namespace, _ object: Object, _ instances: [ModuleInstance], _ text: Text) throws -> Block?
    {
        if text.containsSubstring(" . ")
        {
            let parts = text.split(" . ")
            let sentences = try parts.compactMap { try parseSentence(namespace, object, instances, $0) }
            return Block(sentences)
        }
        else
        {
            guard let sentence = try parseSentence(namespace, object, instances, text) else
            {
                return nil
            }

            return Block([sentence])
        }
    }

    public func parseSentence(_ namespace: Namespace, _ object: Object, _ instances: [ModuleInstance], _ text: Text) throws -> Sentence?
    {
        guard let (subjectText, rest) = try? text.splitOn(" ") else
        {
            return nil
        }

        let subject: Subject
        if subjectText == "self"
        {
            subject = .`self`(object)
        }
        else
        {
            let floatRegex = try Regex("^[0-9]+\\.[0-9]+$")
            let integerRegex = try Regex("^[0-9]+$")

            if subjectText.containsRegex(floatRegex)
            {
                subject = Subject.literal(.float(Double(string: subjectText.toUTF8String())))
            }
            else if subjectText.containsRegex(integerRegex)
            {
                guard let int = Int64(subjectText.toUTF8String()) else
                {
                    return nil
                }

                subject = Subject.literal(.int(int))
            }
            else if namespace.contains(name: subjectText)
            {
                subject = .objectLocal(subjectText)
            }
            else
            {
                return nil
            }
        }

        do
        {
            let chains: [Chain]
            if rest.containsSubstring(" | ")
            {
                chains = try self.parseChains(namespace, subject, rest, object.properties, object.functions)
            }
            else
            {
                let phrases = try self.parsePhrases(namespace, subject, rest, object.properties, object.functions)
                chains = [Chain(phrases: phrases)]
            }

            return Sentence(subject: subject, chains: chains)
        }
        catch
        {
            return nil
        }
    }

    public func parseChains(_ namespace: Namespace, _ subject: Subject, _ text: Text, _ properties: [Property], _ functions: [Function]) throws -> [Chain]
    {
        let parts = text.split(" | ")
        return try parts.compactMap
        {
            part in

            return try parseChain(namespace, subject, part, properties, functions)
        }
    }

    public func parseChain(_ namespace: Namespace, _ subject: Subject, _ text: Text, _ properties: [Property], _ functions: [Function]) throws -> Chain?
    {
        do
        {
            let phrases: [Phrase]
            if text.containsSubstring(" ; ")
            {
                phrases = try self.parsePhrases(namespace, subject, text, properties, functions)
            }
            else
            {
                phrases = [try self.parsePhrase(namespace, subject, text, properties, functions)]
            }

            return Chain(phrases: phrases)
        }
        catch
        {
            return nil
        }
    }


    public func parsePhrases(_ namespace: Namespace, _ subject: Subject, _ text: Text, _ properties: [Property], _ functions: [Function]) throws -> [Phrase]
    {
        let parts = text.split(" ; ")
        return try parts.map
        {
            part in

            return try parsePhrase(namespace, subject, part, properties, functions)
        }
    }

    public func parsePhrase(_ namespace: Namespace, _ subject: Subject, _ text: Text, _ properties: [Property], _ functions: [Function]) throws -> Phrase
    {
        guard text.containsSubstring(" ") else
        {
            // No arguments, this is fine.
            return Phrase(verb: Verb(name: text), arguments: [])
        }

        let parts = text.split(" ")

        guard parts.count >= 2 else
        {
            throw BellParserError.noPart
        }

        let verbText = parts[0]

        let argumentsText: [Text]
        if parts.count > 1
        {
            argumentsText = [Text](parts[1...])
        }
        else
        {
            argumentsText = []
        }

        let verb = Verb(name: verbText)
        let arguments: [Argument] = argumentsText.compactMap
        {
            (argumentText: Text) -> Argument? in

            if argumentText.startsWith(":")
            {
                return Argument.name(argumentText)
            }
            else if namespace.contains(name: argumentText)
            {
                return Argument.objectLocal(argumentText)
            }
            else
            {
                do
                {
                    let floatRegex = try Regex("^[0-9]+\\.[0-9]+$")
                    let integerRegex = try Regex("^[0-9]+$")

                    if argumentText.containsRegex(floatRegex)
                    {
                        return Argument.literal(.float(Double(string: argumentText.toUTF8String())))
                    }
                    else if argumentText.containsRegex(integerRegex)
                    {
                        guard let int = Int64(argumentText.toUTF8String()) else
                        {
                            return nil
                        }

                        return Argument.literal(.int(int))
                    }
                    else
                    {
                        return nil
                    }
                }
                catch
                {
                    return nil
                }
            }
        }

        return Phrase(verb: verb, arguments: arguments)
    }
}
