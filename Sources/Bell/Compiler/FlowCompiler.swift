//
//  FlowCompiler.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/3/23.
//

import Foundation

import Text

extension BellCompiler
{
    public func generateFlows(_ tuple: (Int, Flow)) throws -> String
    {
        let (index, flow) = tuple

        let connections = flow.flows.window2Indexed
        {
            x, y, z in

            if x.containsSubstring(".")
            {
                if y.containsSubstring(".") // input.1 -> output.2
                {
                    let (xname, xport) = try! x.splitOnLast(".")
                    let (yname, yport) = try! y.splitOnLast(".")
                    return """
                    AudioConnection connection\(index)_\(z)a(\(xname.toUTF8String()), \(xport.toUTF8String()), \(yname.toUTF8String()), \(yport.toUTF8String()));
                    """
                }
                else
                {
                    let (xport, xname) = try! x.splitOnLast(".")
                    return """
                    AudioConnection connection\(index)_\(z)a(\(xname.toUTF8String()), \(xport.toUTF8String()), \(y.toUTF8String()), 0);
                    """
                }
            }
            else
            {
                if y.containsSubstring(".") // input.1 -> output.2
                {
                    let (yname, yport) = try! y.splitOnLast(".")
                    return """
                    AudioConnection connection\(index)_\(z)a(\(x.toUTF8String()), 0, \(yname.toUTF8String()), \(yport.toUTF8String());
                    """
                }
                else
                {
                    return """
                    AudioConnection connection\(index)_\(z)a(\(x.toUTF8String()), 0, \(y.toUTF8String()), 0);
                    AudioConnection connection\(index)_\(z)b(\(x.toUTF8String()), 1, \(y.toUTF8String()), 1);
                    """
                }
            }
        }

        return connections.joined(separator: "\n")
    }

}
