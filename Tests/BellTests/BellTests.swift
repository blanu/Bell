import XCTest
@testable import Bell

import Text

final class BellTests: XCTestCase
{
    func testParser() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000
        instance tonesweep : AudioSynthToneSweep
        instance i2s : AudioOutputI2S

        flow tonesweep -> i2s

        object main uses codec tonesweep
        event main setup uses codec tonesweep : codec enable . codec volume 0.5 0.5 . tonesweep play 0.8 256 512 10
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)
    }

    func testParser2() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000

        instance input : AudioInputI2S
        instance tremolo : AudioEffectTremolo
        instance mixer : AudioMixer4
        instance output : AudioOutputI2S

        flow input -> tremolo -> mixer -> output
        flow input -> mixer

        object main uses codec mixer tremolo
        event main setup uses codec mixer tremolo : codec enable ; inputSelect 0 ; muteHeadphone ; micGain 0 ; lineInLevel 5 ; lineOutLevel 20 . mixer gain 0 0.3 ; gain 1 0.7 . tremolo begin 100
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)
    }

    func testParserFunctions() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000

        instance input : AudioInputI2S
        instance tremolo : AudioEffectTremolo
        instance mixer : AudioMixer4
        instance output : AudioOutputI2S

        flow input -> tremolo -> mixer -> output
        flow input -> mixer

        object main uses codec mixer tremolo
        event main setup uses codec mixer tremolo : self setupCodec . self setupMixer . self setupTremolo
        function main setupCodec uses codec : codec enable ; inputSelect 0 ; muteHeadphone ; micGain 0 ; lineInLevel 5 ; lineOutLevel 20
        function main setupMixer uses mixer : mixer gain 0 0.3 ; gain 1 0.7
        function main setupTremolo uses tremolo : tremolo begin 100
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)
    }

    func testCompiler() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000
        instance tonesweep : AudioSynthToneSweep
        instance i2s : AudioOutputI2S

        flow tonesweep -> i2s

        object main uses codec tonesweep
        event main setup uses codec tonesweep : codec enable . codec volume 0.5 0.5 . tonesweep play 0.8 256 512 10
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)

        let url = URL(fileURLWithPath: "/Users/dr.brandonwiley/Documents/Arduino/ClockworkDemo")
        let compiler = try BellCompiler(className: "tonesweep", source: text, output: url)
        try compiler.compile()
    }

    func testCompilerAnalogRead() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000
        instance tonesweep : AudioSynthToneSweep
        instance i2s : AudioOutputI2S

        flow tonesweep -> i2s

        object main uses codec tonesweep
        event main setup uses codec tonesweep : codec enable . codec volume 0.5 0.5 . tonesweep play 0.8 256 512 10
        property main speed : AnalogRead A0
        property main volume : AnalogRead A1
        property main depth : AnalogRead A2
        property main shape : AnalogRead A3
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)

        let url = URL(fileURLWithPath: "/Users/dr.brandonwiley/Documents/Arduino/ClockworkDemo")
        let compiler = try BellCompiler(className: "tonesweep", source: text, output: url)
        try compiler.compile()
    }

    func testCompiler2() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000

        instance input : AudioInputI2S
        instance tremolo : AudioEffectTremolo
        instance mixer : AudioMixer4
        instance output : AudioOutputI2S

        flow input.0 -> tremolo.0 -> mixer.0 -> output.0
        flow input.1              -> mixer.1

        object main uses codec mixer tremolo
        event main setup uses codex mixer tremolo : codec enable ; inputSelect 0 ; muteHeadphone ; micGain 0 ; lineInLevel 5 ; lineOutLevel 20 . mixer gain 0 0.3 ; gain 1 0.7 . tremolo begin 100
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)

        let url = URL(fileURLWithPath: "/Users/dr.brandonwiley/Documents/Arduino/ClockworkDemo")
        let compiler = try BellCompiler(className: "tonesweep", source: text, output: url)
        try compiler.compile()
    }

    func testCompilerFunctions() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000

        instance input : AudioInputI2S
        instance tremolo : AudioEffectTremolo
        instance mixer : AudioMixer4
        instance output : AudioOutputI2S

        flow input -> tremolo -> mixer -> output
        flow input -> mixer

        object main uses codec mixer tremolo
        event main setup uses codec mixer tremolo : self setupCodec . self setupMixer . self setupTremolo
        function main setupCodec uses codec : codec enable ; inputSelect 0 ; micGain 0 ; lineInLevel 5 5 ; lineOutLevel 20
        function main setupMixer uses mixer : mixer gain 0 0.3 ; gain 1 0.7
        function main setupTremolo uses tremolo : tremolo begin 100
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)

        let url = URL(fileURLWithPath: "/Users/dr.brandonwiley/Documents/Arduino/ClockworkDemo")
        let compiler = try BellCompiler(className: "tonesweep", source: text, output: url)
        try compiler.compile()
    }

    func testCompilerUserDefinedEffect() throws
    {
        let text: Text = """
        instance codec : AudioControlSGTL5000

        instance input : AudioInputI2S
        instance tremolo : AudioEffectTremolo
        instance mixer : AudioMixer4
        instance output : AudioOutputI2S

        flow input -> tremolo -> mixer -> output
        flow input -> mixer

        object main uses codec mixer tremolo
        event main setup uses codec mixer tremolo : self setupCodec . self setupMixer . self setupTremolo
        function main setupCodec uses codec : codec enable ; inputSelect 0 ; micGain 0 ; lineInLevel 5 5 ; lineOutLevel 20
        function main setupMixer uses mixer : mixer gain 0 0.3 ; gain 1 0.7
        function main setupTremolo uses tremolo : tremolo begin 100

        audio tremolo
        update tremolo x : x map 1
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)

        let url = URL(fileURLWithPath: "/Users/dr.brandonwiley/Documents/Arduino/ClockworkDemo")
        let compiler = try BellCompiler(className: "tonesweep", source: text, output: url)
        try compiler.compile()
    }
}
