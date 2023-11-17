//
//  Oscillator.swift
//  moog
//
//  Created by Mike Crandall on 10/18/23.
//


import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic
import AVFoundation

import AudioKit
import SoundpipeAudioKit

class OscillatorConductor1: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?
    var tracker: PitchTap?
    var osc = Oscillator()
    
    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? startOsc() : osc.stop() }
    }
    
    init() {
        // Initialize the microphone
        mic = engine.input
        
        // Initialize the PitchTap to analyze the microphone input
        if let mic = engine.input {
            tracker = PitchTap(mic, handler: { pitch, amplitude in
                print("pitchTap")
            })
//            tracker = PitchTap(mic) { pitch, amplitude in
//                DispatchQueue.main.async {
//                    // Use pitch and amplitude data to control the oscillator
//                    // This is a basic example, you'll need to adjust it to your needs
//                    self.osc.frequency = AUValue(pitch[0])
//                    self.osc.amplitude = AUValue(amplitude[0])
//                }
//                print("yo")
//            }
        } else {
            print("error")
        }
        
        // Setting the oscillator as the audio output
        engine.output = osc
    }
    
    func startOsc(){
        osc.start()
        tracker?.start()
    }
    
    func start() {
        do {
            // Start the engine and the pitch tracker
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .mixWithOthers])
            try engine.start()
//            osc.start()
//            tracker.start()
        } catch {
            print("AudioEngine did not start. Error: \(error)")
        }
    }
    
    func stop() {
        // Stop the oscillator, the pitch tracker, and the engine
        osc.stop()
        tracker?.stop()
        engine.stop()
    }
}

struct OscillatorView1: View {
    @StateObject var conductor = OscillatorConductor1()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                    conductor.isPlaying.toggle()
                }
            
            // Any additional UI components can go here
            NodeOutputView(conductor.osc)

        }.onAppear {
            conductor.start()
        }.onDisappear {
            conductor.stop()
        }.background(colorScheme == .dark ? Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

