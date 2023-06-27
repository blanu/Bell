//
//  BellParser.swift
//  Bell
//
//  Created by Dr. Brandon Wiley on 5/1/23.
//

import Foundation

import Text

public class BellParser
{
    public required init()
    {
    }

    public func generateBellProgram(url: URL) throws -> BellProgram
    {
        let bellSource = try String(contentsOfFile: url.path)
        let source = Text(fromUTF8String: bellSource)
        return try self.generateBellProgram(source: source)
    }

    public func generateBellProgram(source: Text) throws -> BellProgram
    {
        let namespace = Namespace()

        let instances = try self.findModuleInstances(namespace, source)
        let flows = try self.findFlows(instances, source)
        let objects = try self.findObjects(namespace, instances, source)

        return BellProgram(instances: instances, flows: flows, objects: objects)
    }

    public func findClassName(_ sourceURL: URL, _ source: String) throws -> String
    {
        return sourceURL.deletingPathExtension().lastPathComponent
    }

}

public enum BellParserError: Error
{
    case noPart
    case wrongType
    case unknownFunction(String)
}
