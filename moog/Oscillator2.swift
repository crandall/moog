//
//  Oscillator2.swift
//  moog
//
//  Created by Mike Crandall on 11/16/23.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class OscillatorConductor2: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?

    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        isPlaying = true
//        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }
    
    func noteOff(pitch _: Pitch) {
        isPlaying = false
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            isPlaying ? osc.start() : osc.stop()
        }
    }
    
    var osc = Oscillator()
    
    init() {
        osc.amplitude = 0.2
//        engine.output = osc
        
        if let input = engine.input {
            mic = input
            if let inputAudio = mic {
                engine.output = osc
            }
        }
        osc.start()
    }
}

struct OscillatorView2: View {
    @StateObject var conductor = OscillatorConductor2()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                    conductor.isPlaying.toggle()
                }
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterRow(param: $0)
                }
            }
            NodeOutputView(conductor.osc)
            CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
            
        }.cookbookNavBarTitle("Oscillator")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
            .background(colorScheme == .dark ?
                        Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}
