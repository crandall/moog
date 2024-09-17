//
//  Conductors.swift
//  moog
//
//  Created by Mike Crandall on 9/17/24.
//

import Foundation
import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFAudio


// Conductor for Microphone Input with Pitch Tracking
class ThereScopeConductor3: ObservableObject, HasAudioEngine {
    @Published var data = ThereScopeData3()
    @Published var gain: AUValue = 1.0
    
    let engine = AudioEngine()
    let initialDevice: Device
    
    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader
    
    var tracker: PitchTap!
    
    init() {
        guard let input = engine.input else { fatalError() }
        
        guard let device = engine.inputDevice else {
            fatalError()
        }
        
        initialDevice = device
        
        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence
        
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise
        guard amp > 0.1 else { return }
        
        data.pitch = pitch
        data.amplitude = amp
        tappableNodeA.gain = gain
    }
    
    func start() {
        try? engine.start()
    }
    
    func stop() {
        engine.stop()
    }
}

// Conductor for Processing Microphone Input into a Square Wave (No Sound Output)
class SquareWaveMicConductor1: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode

    @Published var squareWaveBuffer: [Float] = []
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        
        mic = input
        engine.output = nil // No output to the speakers
    }
    
    func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        var squareWaveData: [Float] = []
        
        for i in 0..<frameLength {
            let sample = channelData[i]
            let squareSample: Float = sample > 0 ? 1.0 : -1.0
            squareWaveData.append(squareSample)
        }
        
        DispatchQueue.main.async {
            self.squareWaveBuffer = squareWaveData
        }
    }
    
    func start() {
        do {
            try engine.start()
            mic.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
                self.processAudio(buffer: buffer)
            }
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func stop() {
        mic.avAudioNode.removeTap(onBus: 0)
        engine.stop()
    }
}


// Conductor for Processing Microphone Input into a Square Wave
class SquareWaveMicConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tappableNode: Fader!
    let silence: Fader

    @Published var squareWaveBuffer: [Float] = []
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        
        mic = input
        tappableNode = Fader(mic)
        silence = Fader(tappableNode, gain: 0)
        engine.output = silence

        
//        engine.output = tappableNode
    }
    
    func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        var squareWaveData: [Float] = []
        
        for i in 0..<frameLength {
            let sample = channelData[i]
            let squareSample: Float = sample > 0 ? 1.0 : -1.0
            squareWaveData.append(squareSample)
        }
        
        DispatchQueue.main.async {
            self.squareWaveBuffer = squareWaveData
        }
    }
    
    func start() {
        do {
            // Start the audio engine
            try engine.start()
            
            // Install the tap after the engine has started
            tappableNode.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
                self.processAudio(buffer: buffer)
            }
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func stop() {
        tappableNode.avAudioNode.removeTap(onBus: 0) // Always remove the tap when stopping
        engine.stop()
    }
}
