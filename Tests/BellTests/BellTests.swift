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
        instance input : AudioInputI2S
        instance mixer : AudioMixer4
        instance tremolo : AudioEffectTremolo
        instance output : AudioOutputI2S

        flow input.0 -> tremolo.0 -> mixer.0 -> output.0
        flow input.1              -> mixer.1

        object control uses codec mixer tremolo

        property control speedKnob : AnalogRead A0
        property control volumeKnob : AnalogRead A1
        property control depthKnob : AnalogRead A2
        property control shapeKnob : AnalogRead A3

        function control speed -> int : speedKnob rescale 0 1023 85 915
        function control volume -> float : volumeKnob normalize 0 1023
        function control rightDepth -> float : depthKnob normalize 0 1023
        function control leftDepth -> float : 1 - rightDepth
        function control rightGain -> float : rightDepth * volume
        function control leftGain -> float : leftDepth * volume
        function control shape -> float : shapeKnob rescale 0 1023 0 1

        event control setup uses codec tremolo : codec enable . codec volume 0.5 0.5 . tremolo begin 200
        event control loop uses codec mixer tremolo : codec volume volume volume . mixer gain 0 leftGain . mixer gain 1 rightGain . tremolo setSpeed speed . tremolo setWaveform shape
        """

        let parser = BellParser()
        let program = try parser.generateBellProgram(source: text)
        print(program.description)

        let url = URL(fileURLWithPath: "/Users/dr.brandonwiley/Documents/Arduino/ClockworkDemo")
        let compiler = try BellCompiler(className: "tonesweep", source: text, output: url)
        try compiler.compile()
    }

    func testCompilerAnalogReadTremoloEffect() throws
    {
        let text: Text = """
        audioEffect tremolo
        event tremolo update x : x * wave
        function tremolo wave : append ones zeros
        function tremolo ones : 1 replicate 100
        function tremolo zeros : 0 replicate 100

        instance codec : AudioControlSGTL5000
        instance input : AudioInputI2S
        instance mixer : AudioMixer4
        instance tremolo : AudioEffectTremolo
        instance output : AudioOutputI2S

        flow input.0 -> tremolo.0 -> mixer.0 -> output.0
        flow input.1              -> mixer.1

        object control uses codec mixer tremolo

        property control speedKnob : AnalogRead A0
        property control volumeKnob : AnalogRead A1
        property control depthKnob : AnalogRead A2
        property control shapeKnob : AnalogRead A3

        function control speed -> int : speedKnob rescale 0 1023 85 915
        function control volume -> float : volumeKnob normalize 0 1023
        function control rightDepth -> float : depthKnob normalize 0 1023
        function control leftDepth -> float : 1 - rightDepth
        function control rightGain -> float : rightDepth * volume
        function control leftGain -> float : leftDepth * volume
        function control shape -> float : shapeKnob rescale 0 1023 0 1

        event control setup uses codec tremolo : codec enable . codec volume 0.5 0.5 . tremolo begin 200
        event control loop uses codec mixer tremolo : codec volume volume volume . mixer gain 0 leftGain . mixer gain 1 rightGain . tremolo setSpeed speed . tremolo setWaveform shape
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
