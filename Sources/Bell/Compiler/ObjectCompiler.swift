//
//  ObjectCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/4/23.
//

import Foundation

import Text

extension BellCompiler
{
    public func generateObjectHeader(_ object: Object) -> String
    {
        return """
        #ifndef _\(object.name.uppercase().toUTF8String())_H_
        #define _\(object.name.uppercase().toUTF8String())_H_
        #include <Arduino.h>
        #include "Audio.h"
        \(object.instances.map { "#include \"\($0.module.toUTF8String())Universe.h\"" }.joined(separator: "\n"))

        class \(object.name.toUTF8String())
        {
            public:
        \(object.eventHandlers.map { self.generateHandlerDeclaration($0) }.joined(separator: "\n"))

            private:
        \(object.functions.map { self.generateFunctionDeclarationText($0) }.joined(separator: "\n"))
        }

        #endif
        """
    }

    public func generateObjectSource(_ object: Object) -> String
    {
        return """
        #include "\(object.name.toUTF8String()).h"

        \(object.eventHandlers.map { self.generateHandlerDefinition(object, $0) }.joined(separator: "\n"))
        """
    }

    public func generateFunctionDeclarationText(_ function: Function) -> String
    {
        let moduleText: String = function.modules.map { return "\($0.module.toUTF8String()) \($0.instanceName.toUTF8String())" }.joined(separator: ", ")

        switch function.arity
        {
            case 0:
                return """
                    void \(function.name)(\(moduleText));
                """
            case 1:
                return """
                    void \(function.name)(x, \(moduleText));
                """
            case 2:
                return """
                    void \(function.name)(x, y, \(moduleText));
                """
            case 3:
                return """
                    void \(function.name)(x, y, z, \(moduleText));
                """

            default:
                print("Unsupported arity \(function.arity)")
                return ""
        }
    }

    public func generateHandlerDeclaration(_ handler: EventHandler) -> String
    {
        let moduleText = handler.modules.map { "\($0.module.toUTF8String())Universe *\($0.instanceName.toUTF8String())Universe"}.joined(separator: ", ")

        return """
                void \(handler.eventName.toUTF8String())(\(moduleText));
        """
    }

    public func generateHandlerDefinition(_ object: Object, _ handler: EventHandler) -> String
    {
        let moduleText: String = handler.modules.map { return "\($0.module.toUTF8String())Universe *\($0.instanceName.toUTF8String())Universe" }.joined(separator: ", ")

        return """
        void \(object.name.toUTF8String())::\(handler.eventName.toUTF8String())(\(moduleText))
        {
        \(handler.block.sentences.map { self.generateSentence($0) }.joined(separator: "\n"))
        }
        """
    }


    public func generateFunctionDefinition(_ function: Function) -> String
    {
        let moduleText: String = function.modules.map { return "\($0.module) \($0.instanceName)" }.joined(separator: ", ")

        switch function.arity
        {
            case 0:
                return """
                    void \(function.name)(\(moduleText))
                    {
                \(self.generateFunctionText(function))
                    }
                """
            case 1:
                return """
                    void \(function.name)(x, \(moduleText))
                    {
                \(self.generateFunctionText(function))
                    }
                """
            case 2:
                return """
                    void \(function.name)(x, y, \(moduleText))
                    {
                \(self.generateFunctionText(function))
                    }
                """
            case 3:
                return """
                    void \(function.name)(x, y, z, \(moduleText))
                    {
                \(self.generateFunctionText(function))
                    }
                """

            default:
                print("Unsupported arity \(function.arity)")
                return ""
        }
    }

    public func generateFunctionText(_ function: Function) -> String
    {
        return function.block.sentences.map { self.generateSentence($0) }.joined(separator: "\n")
    }
}
