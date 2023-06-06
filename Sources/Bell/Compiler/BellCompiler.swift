//
//  BellCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/5/23.
//

import Foundation

import Abacus
import Datable
import Text

public class BellCompiler
{
    let className: Text
    let outputRoot: URL
    let output: URL
    let program: BellProgram

    public init(source: URL, output: URL) throws
    {
        self.className = Text(fromUTF8String: source.deletingPathExtension().lastPathComponent)
        self.output = output
        self.outputRoot = output
        let parser = BellParser()
        self.program = try parser.generateBellProgram(url: source)
    }

    public init(className: Text, source: Text, output: URL) throws
    {
        self.className = className
        self.outputRoot = output
        self.output = output.appendingPathComponent("\(className.toUTF8String()).ino")
        let parser = BellParser()
        self.program = try parser.generateBellProgram(source: source)
    }

    public func compile() throws
    {
        let inosource = try generateIno(self.className, self.program)
        print(inosource)
        print("Writing \(className.toUTF8String()).ino...")
        try inosource.write(to: self.output, atomically: true, encoding: .utf8)

        for object in self.program.objects
        {
            print("Writing \(object.name.toUTF8String()).hpp...")
            let objectHeaderOutput = self.outputRoot.appendingPathComponent("\(object.name.toUTF8String()).hpp")
            let objectHeader = try generateObjectHeader(object)
            try objectHeader.write(to: objectHeaderOutput, atomically: true, encoding: .utf8)

            print("Writing \(object.name.toUTF8String()).cpp...")
            let objectSourceOutput = self.outputRoot.appendingPathComponent("\(object.name.toUTF8String()).cpp")
            let objectSource = try generateObjectSource(object)
            try objectSource.write(to: objectSourceOutput, atomically: true, encoding: .utf8)
        }

        print("Done.")
    }

    public func generateIno(_ className: Text, _ program: BellProgram) throws -> String
    {
        let setupObjects = program.objects.filter
        {
            object in

            let setups = object.eventHandlers.filter
            {
                handler in

                return handler.eventName == "setup"
            }

            return setups.count > 0
        }

        let loopObjects = program.objects.filter
        {
            object in

            let setups = object.eventHandlers.filter
            {
                handler in

                return handler.eventName == "loop"
            }

            return setups.count > 0
        }

        let setupHandlerText = setupObjects.map { self.generateHandlerText($0.name, "setup") } .joined(separator: "\n")
        let loopHandlerText = loopObjects.map { self.generateHandlerText($0.name, "loop") } .joined(separator: "\n")

        return """
        #include <Arduino.h>
        #include "Audio.h"
        \(program.objects.map { self.generateObjectInclude($0) }.joined(separator: "\n"))
        \(program.instances.map { self.generateInclude($0) }.joined(separator: "\n"))

        \(program.instances.map { self.generateInstance($0) }.joined(separator: "\n"))

        \(try program.objects.map { try self.generateObjectReference($0) }.joined(separator: "\n"))
        
        \(program.flows.enumerated().map { try! self.generateFlows($0) }.joined(separator: "\n"))

        void setup()
        {
        \(setupHandlerText)
        }

        void loop()
        {
        \(loopHandlerText)
        }
        """
    }

    public func generateInclude(_ instance: ModuleInstance) -> String
    {
        return """
        #include "\(instance.module.toUTF8String())Module.h"
        #include "\(instance.module.toUTF8String())Universe.h"
        """
    }

    public func generateObjectInclude(_ object: Object) -> String
    {
        return """
        #include "\(object.name.toUTF8String()).hpp"
        """
    }

    public func generateObjectReference(_ object: Object) throws -> String
    {
        return "\(try object.name.uppercaseFirstLetter().toUTF8String()) \(object.name.toUTF8String())(\(object.instances.map { self.makeConstructorArgument($0) }.joined(separator: ", ")));"
    }
}
