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
    public func generateObjectHeader(_ object: Object) throws -> String
    {
        return """
        #ifndef _\(object.name.uppercase().toUTF8String())_H_
        #define _\(object.name.uppercase().toUTF8String())_H_
        #include <Arduino.h>
        #include "Audio.h"
        \(object.instances.map { "#include \"\($0.module.toUTF8String())Universe.h\"" }.joined(separator: "\n"))

        class \(try object.name.uppercaseFirstLetter().toUTF8String())
        {
            public:
        \(try self.generateConstructor(object))
        \(object.eventHandlers.map { self.generateHandlerDeclaration($0) }.joined(separator: "\n"))

            private:
        \(object.functions.map { self.generateFunctionDeclarationText($0) }.joined(separator: "\n"))

        \(object.instances.map { self.generateInstanceVariable($0) }.joined(separator: "\n"))
        };

        #endif
        """
    }

    public func generateConstructor(_ object: Object) throws -> String
    {
        let name = try object.name.uppercaseFirstLetter().toUTF8String()
        let parameters = object.instances.map { return self.makeConstructorParameter($0) }.joined(separator: ", ")
        let initializers = object.instances.map { return self.makeConstructorInitializer($0) }.joined(separator: ", ")
        return "        \(name)(\(parameters)) : \(initializers) {}"
    }

    public func makeConstructorArgument(_ instance: ModuleInstance) -> String
    {
        return "&\(instance.instanceName.toUTF8String())Universe"
    }

    public func makeConstructorParameter(_ instance: ModuleInstance) -> String
    {
        return "\(instance.module.toUTF8String())Universe *\(instance.instanceName.toUTF8String())"
    }

    public func makeConstructorInitializer(_ instance: ModuleInstance) -> String
    {
        return "\(instance.instanceName.toUTF8String())(\(instance.instanceName.toUTF8String()))"
    }

    public func generateInstanceVariable(_ instance: ModuleInstance) -> String
    {
        return "        \(instance.module.toUTF8String())Universe *\(instance.instanceName.toUTF8String());"
    }

    public func generateObjectSource(_ object: Object) throws -> String
    {
        return """
        #include "\(object.name.toUTF8String()).hpp"

        \(try object.eventHandlers.map { try self.generateHandlerDefinition(object, $0) }.joined(separator: "\n"))

        \(try object.functions.map { try self.generateFunctionDefinition(object, $0) }.joined(separator: "\n\n"))
        """
    }

    public func generateFunctionDeclarationText(_ function: Function) -> String
    {
        switch function.arity
        {
            case 0:
                return """
                        void \(function.name.toUTF8String())();
                """
            case 1:
                return """
                        void \(function.name.toUTF8String())(x);
                """
            case 2:
                return """
                        void \(function.name.toUTF8String())(x, y);
                """
            case 3:
                return """
                        void \(function.name.toUTF8String())(x, y, z);
                """

            default:
                print("Unsupported arity \(function.arity)")
                return ""
        }
    }

    public func generateHandlerDeclaration(_ handler: EventHandler) -> String
    {
        return """
                void \(handler.eventName.toUTF8String())();
        """
    }

    public func generateHandlerDefinition(_ object: Object, _ handler: EventHandler) throws -> String
    {
        return """
        void \(try object.name.uppercaseFirstLetter().toUTF8String())::\(handler.eventName.toUTF8String())()
        {
        \(handler.block.sentences.map { self.generateSentence($0) }.joined(separator: "\n"))
        }
        """
    }


    public func generateFunctionDefinition(_ object: Object, _ function: Function) throws -> String
    {
        switch function.arity
        {
            case 0:
                return """
                void \(try object.name.uppercaseFirstLetter().toUTF8String())::\(function.name.toUTF8String())()
                {
                \(self.generateFunctionText(function))
                }
                """
            case 1:
                return """
                void \(try object.name.uppercaseFirstLetter().toUTF8String())::\(function.name.toUTF8String())(x)
                {
                \(self.generateFunctionText(function))
                }
                """
            case 2:
                return """
                void \(try object.name.uppercaseFirstLetter().toUTF8String())::\(function.name.toUTF8String())(x, y)
                {
                \(self.generateFunctionText(function))
                }
                """
            case 3:
                return """
                void \(try object.name.uppercaseFirstLetter().toUTF8String())::\(function.name.toUTF8String())(x, y, z)
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
