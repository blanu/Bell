//
//  AudioEffectCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/27/23.
//

import Foundation

import Text

extension BellCompiler
{
    public func generateEffectHeader(_ object: Object) throws -> String
    {
        return """
        #ifndef _\(object.name.uppercase().toUTF8String())_H_
        #define _\(object.name.uppercase().toUTF8String())_H_
        #include <Arduino.h>
        #include "AudioStream.h"
        \(object.instances.map { "#include \"\($0.module)Universe.h\"" }.joined(separator: "\n"))

        class \(try object.name.uppercaseFirstLetter()) : public AudioStream
        {
            public:
        \(try self.generateEffectConstructor(object))
        \(object.eventHandlers.map { self.generateHandlerDeclaration($0) }.joined(separator: "\n"))
        \(try object.properties.map { try self.generatePropertyDeclaration($0) }.joined(separator: "\n"))

            private:
                audio_block_t *inputQueueArray[1];

        \(object.functions.map { self.generateFunctionDeclarationText($0) }.joined(separator: "\n"))

        \(object.instances.map { self.generateInstanceVariable($0) }.joined(separator: "\n"))
        };

        #endif
        """
    }

    public func generateEffectConstructor(_ object: Object) throws -> String
    {
        let name = try object.name.uppercaseFirstLetter().toUTF8String()
        let parameters = object.instances.map { return self.makeConstructorParameter($0) }.joined(separator: ", ")
        let initializers = object.instances.map { return self.makeConstructorInitializer($0) }.joined(separator: ", ")

        if object.instances.isEmpty
        {
            return "        \(name)(\(parameters)) : AudioStream(1, inputQueueArray) {}"
        }
        else
        {
            return "        \(name)(\(parameters)) : AudioStream(1, inputQueueArray), \(initializers) {}"
        }
    }

    public func generateEffectSource(_ object: Object) throws -> String
    {
        guard let update = object.eventHandlers.first(where: { $0.eventName == "update" }) else
        {
            throw AudioEffectCompilerError.audioEffectRequiredUpdateHandler
        }

        return """
        #include "\(object.name.toUTF8String()).hpp"

        void \(try object.name.uppercaseFirstLetter())::update(void)
        {
            audio_block_t *x = receiveWritable(0);
            if (!x) return;

        \(try update.block.sentences.map { try self.generateSentence(object, $0) }.joined(separator: "\n"))

            transmit(x, 0);
            release(x);
        }

        \(try object.eventHandlers.filter { $0.eventName != "update" }.map { try self.generateHandlerDefinition(object, $0) }.joined(separator: "\n"))

        \(try object.functions.map { try self.generateFunctionDefinition(object, $0) }.joined(separator: "\n\n"))
        """
    }
}

public enum AudioEffectCompilerError: Error
{
    case badNumberOfParts
    case badEffectType(Text)
    case audioEffectRequiredUpdateHandler
}
