//
//  Waveform.swift
//  moog
//
//  Created by Mike Crandall on 11/29/23.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class WaveformConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        isPlaying = true
        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }
    
    func noteOff(pitch _: Pitch) {
        isPlaying = false
    }
    
    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? osc.start() : osc.stop() }
    }
    
    var osc = DynamicOscillator()
    
    init() {
        osc.amplitude = 0.2
        engine.output = osc
    }
}

struct WaveformView: View {
    @StateObject var conductor = WaveformConductor()
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedWaveform: String? = nil
    @State private var nodeOutputColor: Color = Color.plotColor
    
    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                    conductor.isPlaying.toggle()
                }
            Spacer()
            HStack {
                Spacer()
                Text("Sine")
                    .foregroundColor(selectedWaveform == "sine" ? .blue : .black)
                    .onTapGesture {
                        conductor.osc.setWaveform(Table(.sine))
                        selectedWaveform = "sine"
                    }
                Spacer()
                Text("Square")
                    .foregroundColor(selectedWaveform == "square" ? .blue : .black)
                    .onTapGesture {
                        conductor.osc.setWaveform(Table(.square))
                        selectedWaveform = "square"
                    }
                Spacer()
                Text("Triangle")
                    .foregroundColor(selectedWaveform == "triangle" ? .blue : .black)
                    .onTapGesture {
                        conductor.osc.setWaveform(Table(.triangle))
                        selectedWaveform = "triangle"
                    }
                Spacer()
                Text("Sawtooth")
                    .foregroundColor(selectedWaveform == "sawtooth" ? .blue : .black)
                    .onTapGesture {
                        conductor.osc.setWaveform(Table(.sawtooth))
                        selectedWaveform = "sawtooth"
                    }
                Spacer()
            }
            Spacer()
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterRow(param: $0)
                }
            }
            
            
            NodeOutputView(conductor.osc, color: nodeOutputColor, backgroundColor: .black, bufferSize: 1024)
            CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
        }.cookbookNavBarTitle("Waveform")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
            .background(colorScheme == .dark ? Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}


