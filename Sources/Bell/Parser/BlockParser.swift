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
    func parseBlock(_ object: Object, _ instances: [ModuleInstance], _ text: Text) -> Block?
    {
        if text.containsSubstring(" . ")
        {
            let parts = text.split(" . ")
            let sentences = parts.compactMap { parseSentence(object, instances, $0) }
            return Block(sentences)
        }
        else
        {
            guard let sentence = parseSentence(object, instances, text) else
            {
                return nil
            }

            return Block([sentence])
        }
    }

    public func parseSentence(_ object: Object, _ instances: [ModuleInstance], _ text: Text) -> Sentence?
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
            let maybeSubject = instances.first
            {
                instance in

                return instance.instanceName == subjectText
            }

            guard let actualSubject = maybeSubject else
            {
                return nil
            }

            subject = .instance(actualSubject)
        }

        do
        {
            let chains: [Chain]
            if rest.containsSubstring(" | ")
            {
                chains = try self.parseChains(subject, rest)
            }
            else
            {
                let phrases = try self.parsePhrases(subject, rest)
                chains = [Chain(phrases: phrases)]
            }

            return Sentence(subject: subject, chains: chains)
        }
        catch
        {
            return nil
        }
    }

    public func parseChains(_ subject: Subject, _ text: Text) throws -> [Chain]
    {
        let parts = text.split(" | ")
        return try parts.compactMap
        {
            part in

            return try parseChain(subject, part)
        }
    }

    public func parseChain(_ subject: Subject, _ text: Text) throws -> Chain?
    {
        do
        {
            let phrases: [Phrase]
            if text.containsSubstring(" ; ")
            {
                phrases = try self.parsePhrases(subject, text)
            }
            else
            {
                phrases = [try self.parsePhrase(subject, text)]
            }

            return Chain(phrases: phrases)
        }
        catch
        {
            return nil
        }
    }


    public func parsePhrases(_ subject: Subject, _ text: Text) throws -> [Phrase]
    {
        let parts = text.split(" ; ")
        return try parts.map
        {
            part in

            return try parsePhrase(subject, part)
        }
    }

    public func parsePhrase(_ subject: Subject, _ text: Text) throws -> Phrase
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
