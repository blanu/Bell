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
    public func generateSentence(_ object: Object, _ sentence: Sentence) throws -> String
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
                    return try self.generatePhrases(object, sentence.subject, instance.instanceName.toUTF8String(), sentence.chains[0].phrases) + ";\n"
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return try self.generateOnlyChains(object, sentence.subject, instance.instanceName.toUTF8String(), sentence.chains) + ";\n"
                }
                else
                {
                    return self.generateChainsAndPhrases(object, sentence.subject, instance.instanceName.toUTF8String(), sentence.chains) + ";\n"
                }

            case .`self`(_):
                if sentence.chains.count == 0
                {
                    return ""
                }
                else if sentence.chains.count == 1
                {
                    return try self.generatePhrases(object, sentence.subject, "this", sentence.chains[0].phrases)
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return try self.generateOnlyChains(object, sentence.subject, "this", sentence.chains)
                }
                else
                {
                    return self.generateChainsAndPhrases(object, sentence.subject, "this", sentence.chains)
                }

            case .objectLocal(var name):
                if object.properties.contains(where: { $0.name == name })
                {
                    name = Text(fromUTF8String: "this->\(name)")
                }
                else if object.functions.contains(where: { $0.name == name })
                {
                    name = Text(fromUTF8String: "this->\(name)()")
                }

                if sentence.chains.count == 0
                {
                    return ""
                }
                else if sentence.chains.count == 1
                {
                    return try self.generatePhrases(object, sentence.subject, name.toUTF8String(), sentence.chains[0].phrases)
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return try self.generateOnlyChains(object, sentence.subject, name.toUTF8String(), sentence.chains)
                }
                else
                {
                    return self.generateChainsAndPhrases(object, sentence.subject, name.toUTF8String(), sentence.chains)
                }

            case .literal(let literal):
                if sentence.chains.count == 0
                {
                    return ""
                }
                else if sentence.chains.count == 1
                {
                    return try self.generatePhrases(object, sentence.subject, literal.description, sentence.chains[0].phrases)
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return try self.generateOnlyChains(object, sentence.subject, literal.description, sentence.chains)
                }
                else
                {
                    return self.generateChainsAndPhrases(object, sentence.subject, literal.description, sentence.chains)
                }

            case .parameter(name: let name, type: _):
                if sentence.chains.count == 0
                {
                    return ""
                }
                else if sentence.chains.count == 1
                {
                    return try self.generatePhrases(object, sentence.subject, name.toUTF8String(), sentence.chains[0].phrases)
                }
                else if sentence.chains.filter({ $0.phrases.count != 1 }).isEmpty // Each chain contains exactly one phrase.
                {
                    return try self.generateOnlyChains(object, sentence.subject, name.toUTF8String(), sentence.chains)
                }
                else
                {
                    return self.generateChainsAndPhrases(object, sentence.subject, name.toUTF8String(), sentence.chains)
                }
        }
    }

    public func generateOnlyChains(_ object: Object, _ subject: Subject, _ instanceName: String, _ chains: [Chain]) throws -> String
    {
        if instanceName == "this"
        {
            return try "\(chains.map { try self.generateChain(object, subject, instanceName, $0) }.joined(separator: "."));\n"
        }
        else
        {
            return try "\(instanceName)->\(chains.map { try self.generateChain(object, subject, instanceName, $0) }.joined(separator: "."));\n"
        }
    }

    public func generateChain(_ object: Object, _ subject: Subject, _ instanceName: String, _ chain: Chain) throws -> String
    {
        return try chain.phrases.map { try self.generatePhrase(object, subject, instanceName, $0) }.joined(separator: "\n")
    }

    public func generatePhrase(_ object: Object, _ subject: Subject, _ phrase: Phrase) throws -> String
    {
        return "\(phrase.verb.name.toUTF8String())(\(try self.generateArguments(object, phrase.arguments)));"
    }

    public func generatePhrases(_ object: Object, _ subject: Subject, _ instanceName: String, _ phrases: [Phrase]) throws -> String
    {
        if phrases.count == 0
        {
            return ""
        }
        else if phrases.count == 1
        {
            return try self.generatePhrase(object, subject, instanceName, phrases[0])
        }
        else
        {
            return try phrases.map { try self.generatePhrase(object, subject, instanceName, $0) }.joined(separator: "\n")
        }
    }

    public func generatePhrase(_ object: Object, _ subject: Subject, _ instanceName: String, _ phrase: Phrase) throws -> String
    {
        if self.isSpecializedVerb(phrase.verb)
        {
            return try self.generateSpecializedVerb(object, subject, instanceName, phrase)
        }
        else
        {
            if instanceName == "this"
            {
                return "\(phrase.verb.name)(\(try self.generateArguments(object, phrase.arguments)));"
            }
            else
            {
                return "\(instanceName)->\(phrase.verb.name)(\(try self.generateArguments(object, phrase.arguments)));"
            }
        }
    }

    public func isSpecializedVerb(_ verb: Verb) -> Bool
    {
        return SpecializedVerb(rawValue: verb.name.toUTF8String()) != nil
    }

    public func generateSpecializedVerb(_ object: Object, _ subject: Subject, _ instanceName: String, _ phrase: Phrase) throws -> String
    {
        guard let verb = SpecializedVerb(rawValue: phrase.verb.name.toUTF8String()) else
        {
            throw BellCompilerError.unknownSpecializedVerb
        }

        let subjectType = object.getSubjectType(subject)

        switch subjectType
        {
            case "#int":
                switch verb
                {
                    case .add:
                        //return "\(instanceName) + \(try self.generateArguments(object, phrase.arguments))"
                        return "FIXME"

                    case .subtract:
//                        return "\(instanceName) - \(try self.generateArguments(object, phrase.arguments))"
                        return "FIXME"

                    case .multiply:
                        guard instanceName == "x" else
                        {
                            return "FAILED"
                        }

                        return """
                            for(int index = 0; index < AUDIO_SAMPLE_BLOCK ; index++)
                            {
                                x[index] = x[index] * \(try self.generateArguments(object, phrase.arguments))
                            }
                        """

                    case .divide:
//                        return "\(instanceName) / \(try self.generateArguments(object, phrase.arguments))"
                        return "FIXME"

                    case .rescale:
//                        guard phrase.arguments.count == 4 else
//                        {
//                            throw BellCompilerError.badArity
//                        }
//
//                        let lowerStart = phrase.arguments[0]
//                        let upperStart = phrase.arguments[1]
//                        let lowerEnd = phrase.arguments[2]
//                        let upperEnd = phrase.arguments[3]
//
//                        return "int((float)(\(instanceName) - \(lowerStart)) / (float)(\(upperStart) - \(lowerStart))) * (\(upperEnd) - \(lowerEnd)) + \(lowerEnd)"
                        return "FIXME"

                    case .normalize:
//                        guard phrase.arguments.count == 2 else
//                        {
//                            throw BellCompilerError.badArity
//                        }
//
//                        let lower = phrase.arguments[0]
//                        let upper = phrase.arguments[1]
//
//                        return "(float)(\(instanceName) - \(lower)) / (float)(\(upper) - \(lower))"
                        return "FIXME"
                }

            case "int":
                switch verb
                {
                    case .add:
                        return "\(instanceName) + \(try self.generateArguments(object, phrase.arguments))"

                    case .subtract:
                        return "\(instanceName) - \(try self.generateArguments(object, phrase.arguments))"

                    case .multiply:
                        return "\(instanceName) * \(try self.generateArguments(object, phrase.arguments))"

                    case .divide:
                        return "\(instanceName) / \(try self.generateArguments(object, phrase.arguments))"

                    case .rescale:
                        guard phrase.arguments.count == 4 else
                        {
                            throw BellCompilerError.badArity
                        }

                        let lowerStart = phrase.arguments[0]
                        let upperStart = phrase.arguments[1]
                        let lowerEnd = phrase.arguments[2]
                        let upperEnd = phrase.arguments[3]

                        return "int((float)(\(instanceName) - \(lowerStart)) / (float)(\(upperStart) - \(lowerStart))) * (\(upperEnd) - \(lowerEnd)) + \(lowerEnd)"

                    case .normalize:
                        guard phrase.arguments.count == 2 else
                        {
                            throw BellCompilerError.badArity
                        }

                        let lower = phrase.arguments[0]
                        let upper = phrase.arguments[1]

                        return "(float)(\(instanceName) - \(lower)) / (float)(\(upper) - \(lower))"
                }

            case "float":
                switch verb
                {
                    case .add:
                        return "\(instanceName) + \(try self.generateArguments(object, phrase.arguments))"

                    case .subtract:
                        return "\(instanceName) - \(try self.generateArguments(object, phrase.arguments))"

                    case .multiply:
                        return "\(instanceName) * \(try self.generateArguments(object, phrase.arguments))"

                    case .divide:
                        return "\(instanceName) / \(try self.generateArguments(object, phrase.arguments))"

                    case .rescale:
                        guard phrase.arguments.count == 4 else
                        {
                            throw BellCompilerError.badArity
                        }

                        let lowerStart = phrase.arguments[0]
                        let upperStart = phrase.arguments[1]
                        let lowerEnd = phrase.arguments[2]
                        let upperEnd = phrase.arguments[3]

                        return "int((float)(\(instanceName) - \(lowerStart)) / (float)(\(upperStart) - \(lowerStart))) * (\(upperEnd) - \(lowerEnd)) + \(lowerEnd)"

                    case .normalize:
                        guard phrase.arguments.count == 2 else
                        {
                            throw BellCompilerError.badArity
                        }

                        let lower = phrase.arguments[0]
                        let upper = phrase.arguments[1]

                        return "(float)(\(instanceName) - \(lower)) / (float)(\(upper) - \(lower))"
                }

            default:
                throw BellCompilerError.unknownSubject(subjectType)
        }
    }

    public func generateChainsAndPhrases(_ object: Object, _ subject: Subject, _ instanceName: String, _ chains: [Chain]) -> String
    {
        return "" // FIXME
    }

    public func generateArguments(_ object: Object, _ arguments: [Argument]) throws -> String
    {
        if arguments.count == 0
        {
            return ""
        }
        else if arguments.count == 1
        {
            return try self.generateArgument(object, arguments[0])
        }
        else
        {
            return try arguments.map { try self.generateArgument(object, $0) }.joined(separator: ", ")
        }
    }

    public func generateArgument(_ object: Object, _ argument: Argument) throws -> String
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

            case .objectLocal(let name):
                if object.functions.contains(where: { $0.name == name})
                {
                    return "this->\(name)()"
                }
                else if object.properties.contains(where: { $0.name == name })
                {
                    return "this->\(name)"
                }
                else
                {
                    throw BellCompilerError.couldNotFindSymbolInObject(name.toUTF8String())
                }
        }
    }
}

public enum BellCompilerError: Error
{
    case unknownSpecializedVerb
    case badArity
    case couldNotFindSymbolInObject(String)
    case unknownSubject(String)
}
