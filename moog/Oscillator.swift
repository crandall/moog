//
//  Oscillator.swift
//  moog
//
//  Created by Mike Crandall on 10/18/23.
//

//import AudioKit
//import AudioKitEX
//import AudioKitUI
//import AudioToolbox
//import Keyboard
//import SoundpipeAudioKit
//import SwiftUI
//import Tonic
//
//class OscillatorConductor: ObservableObject, HasAudioEngine {
//    let engine = AudioEngine()
//    
//    func noteOn(pitch: Pitch, point _: CGPoint) {
//        isPlaying = true
//        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
//    }
//    
//    func noteOff(pitch _: Pitch) {
//        isPlaying = false
//    }
//    
//    @Published var isPlaying: Bool = false {
//        didSet { isPlaying ? osc.start() : osc.stop() }
//    }
//    
//    var osc = Oscillator()
//    
//    init() {
//        osc.amplitude = 0.2
//        engine.output = osc
//    }
//}
//
//
//
//struct OscillatorView1: View {
//    @StateObject var conductor = OscillatorConductor()
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        VStack {
//            Text(conductor.isPlaying ? "STOP" : "START")
//                .foregroundColor(.blue)
//                .onTapGesture {
//                    conductor.isPlaying.toggle()
//                }
//            HStack {
//                ForEach(conductor.osc.parameters) {
//                    ParameterRow(param: $0)
//                }
//            }
//            NodeOutputView(conductor.osc)
//            CookbookKeyboard(noteOn: conductor.noteOn,
//                             noteOff: conductor.noteOff)
//            
//        }.cookbookNavBarTitle("Oscillator")
//            .onAppear {
//                conductor.start()
//            }
//            .onDisappear {
//                conductor.stop()
//            }
//            .background(colorScheme == .dark ?
//                        Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
//    }
//}

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI


class OscillatorConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?
    var osc = DynamicOscillator()
    
//    var osc = DynamicOscillator()
    
//    init() {
//        osc.amplitude = 0.2
//        engine.output = osc
//    }

    init() {
        mic = engine.input
//        osc.amplitude = 0.2
        osc.amplitude = 1.0
        engine.output = osc

//        if let micNode = mic {
//            let mixer = Mixer(osc, micNode)
//            engine.output = mixer
//        } else {
//            engine.output = osc
//        }
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            print("AudioKit did not start!")
        }
    }
    
    func stop() {
        engine.stop()
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                osc.start()
            } else {
                osc.stop()
            }
        }
    }
}

struct OscillatorView1: View {
    @StateObject var conductor = OscillatorConductor()
    @State private var nodeOutputColor: Color = Color(red: 66/255, green: 110/255, blue: 244/255, opacity: 1.0)

    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                    conductor.isPlaying.toggle()
                }
            NodeOutputView(conductor.osc, color: nodeOutputColor, backgroundColor: .black, bufferSize: 1024)
//            NodeOutputView(conductor.osc)
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}

//struct OscillatorView1: View {
//    @StateObject var conductor = OscillatorConductor()
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        VStack {
//            Text(conductor.isPlaying ? "STOP" : "START")
//                .foregroundColor(.blue)
//                .onTapGesture {
//                    conductor.isPlaying.toggle()
//                }
//            HStack {
//                ForEach(conductor.osc.parameters) { param in
//                    ParameterRow(param: param)
//                }
//            }
//            if let mic = conductor.mic {
//                NodeOutputView(mic)
//            }
//        }
//        .onAppear {
//            conductor.start()
//        }
//        .onDisappear {
//            conductor.stop()
//        }
//        .background(colorScheme == .dark ?
//                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
//    }
//}
