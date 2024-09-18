//
//  Conductors.swift
//  moog
//
//  Created by Mike Crandall on 9/18/24.
//

import Foundation
import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFAudio

// MARK: -- TriangleWave

class TriangleWaveConductor: ObservableObject {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tracker: PitchTap!
    let oscillator: Oscillator  // Oscillator with custom triangle waveform
    let silentNode: Fader       // Fader to mute output
    
    @Published var pitch: AUValue = 0.0  // Detected pitch
    @Published var amplitude: AUValue = 0.0  // Detected amplitude
    @Published var triangleWaveData: [Float] = []  // Triangle wave data for plotting
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        mic = input
        
        // Define a custom triangle waveform
        let triangleWaveform = Table(.triangle)
        
        // Use an Oscillator with the custom triangle waveform
        oscillator = Oscillator(waveform: triangleWaveform)
        oscillator.amplitude = 0.5  // Default amplitude, can be adjusted
        
        // Create a fader node to make the oscillator output silent
        silentNode = Fader(oscillator, gain: 0.0)  // Set gain to 0 to mute output
        
        // Set the silent node as the output of the audio engine
        engine.output = silentNode
        
        // Start pitch detection
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.pitch = pitch[0]  // Detected pitch (frequency)
                self.amplitude = amp[0]  // Detected amplitude
                self.updateTriangleWave()
            }
        }
        
        // Attach a tap to capture the waveform data for visualization
        oscillator.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            let channelData = buffer.floatChannelData![0]  // Accessing the waveform data
            let frameLength = Int(buffer.frameLength)
            var waveData: [Float] = []
            
            for i in 0..<frameLength {
                waveData.append(channelData[i])
            }
            
            DispatchQueue.main.async {
                self.triangleWaveData = waveData  // Update the waveform data
            }
        }
        
        tracker.start()
    }
    
    func updateTriangleWave() {
        // Set oscillator frequency to detected pitch
        oscillator.frequency = self.pitch
        // Set oscillator amplitude based on input amplitude
        oscillator.amplitude = self.amplitude
    }
    
    func start() {
        do {
            try engine.start()
            oscillator.start()
        } catch {
            print("Error starting the audio engine: \(error)")
        }
    }
    
    func stop() {
        engine.stop()
        oscillator.stop()
    }
}

struct TriangleWavePlot: View {
    var triangleWaveData: [Float]  // Triangle wave data to plot
    var amplitudeScale: CGFloat    // Dynamically adjust height based on volume
    var widthScale: CGFloat        // Dynamically adjust width based on pitch
    var minAmplitudeThreshold: CGFloat = 0.01 // Threshold to flatten wave at low volume
    var minAmplitudeScale: CGFloat = 0.1      // Minimum wave height
    var minWidthScale: CGFloat = 0.5          // Minimum wave width
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                
                // Calculate step size based on widthScale
                let step = max((width / CGFloat(max(1, triangleWaveData.count))) * widthScale, minWidthScale)
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot triangle wave - linearly interpolate between peaks
                for i in 0..<triangleWaveData.count {
                    let x = CGFloat(i) * step
                    
                    // Scale the amplitude of the wave using effectiveAmplitudeScale
                    let y = (height / 2) - CGFloat(triangleWaveData[i]) * (height / 2) * amplitudeScale
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.red, lineWidth: 2)  // Use a distinctive color
        }
    }
}

// MARK: -- SquareWave

class SquareWaveConductor: ObservableObject {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tracker: PitchTap!
    let oscillator: Oscillator  // Oscillator with custom triangle waveform
    let silentNode: Fader       // Fader to mute output
    
    @Published var pitch: AUValue = 0.0  // Detected pitch
    @Published var amplitude: AUValue = 0.0  // Detected amplitude
    @Published var squareWaveData: [Float] = []  // Triangle wave data for plotting
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        mic = input
        
        // Define a custom square waveform
        let squareWaveform = Table(.square)
        
        // Use an Oscillator with the custom triangle waveform
        oscillator = Oscillator(waveform: squareWaveform)
        oscillator.amplitude = 0.5  // Default amplitude, can be adjusted
        
        // Create a fader node to make the oscillator output silent
        silentNode = Fader(oscillator, gain: 0.0)  // Set gain to 0 to mute output
        
        // Set the silent node as the output of the audio engine
        engine.output = silentNode
        
        // Start pitch detection
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.pitch = pitch[0]  // Detected pitch (frequency)
                self.amplitude = amp[0]  // Detected amplitude
                self.updateSquareWave()
            }
        }
        
        // Attach a tap to capture the waveform data for visualization
        oscillator.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            let channelData = buffer.floatChannelData![0]  // Accessing the waveform data
            let frameLength = Int(buffer.frameLength)
            var waveData: [Float] = []
            
            for i in 0..<frameLength {
                waveData.append(channelData[i])
            }
            
            DispatchQueue.main.async {
                self.squareWaveData = waveData  // Update the waveform data
            }
        }
        
        tracker.start()
    }
    
    func updateSquareWave() {
        // Set oscillator frequency to detected pitch
        oscillator.frequency = self.pitch
        // Set oscillator amplitude based on input amplitude
        oscillator.amplitude = self.amplitude
    }
    
    func start() {
        do {
            try engine.start()
            oscillator.start()
        } catch {
            print("Error starting the audio engine: \(error)")
        }
    }
    
    func stop() {
        engine.stop()
        oscillator.stop()
    }
}

struct SquareWavePlot: View {
    var squareWaveData: [Float]  // Triangle wave data to plot
    var amplitudeScale: CGFloat    // Dynamically adjust height based on volume
    var widthScale: CGFloat        // Dynamically adjust width based on pitch
    var minAmplitudeThreshold: CGFloat = 0.01 // Threshold to flatten wave at low volume
    var minAmplitudeScale: CGFloat = 0.1      // Minimum wave height
    var minWidthScale: CGFloat = 0.5          // Minimum wave width
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                
                // Calculate step size based on widthScale
                let step = max((width / CGFloat(max(1, squareWaveData.count))) * widthScale, minWidthScale)
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot triangle wave - linearly interpolate between peaks
                for i in 0..<squareWaveData.count {
                    let x = CGFloat(i) * step
                    
                    // Scale the amplitude of the wave using effectiveAmplitudeScale
                    let y = (height / 2) - CGFloat(squareWaveData[i]) * (height / 2) * amplitudeScale
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.red, lineWidth: 2)  // Use a distinctive color
        }
    }
}

// MARK: -- SawtoothWave

class SawtoothWaveConductor: ObservableObject {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tracker: PitchTap!
    let oscillator: Oscillator  // Oscillator with custom triangle waveform
    let silentNode: Fader       // Fader to mute output
    
    @Published var pitch: AUValue = 0.0  // Detected pitch
    @Published var amplitude: AUValue = 0.0  // Detected amplitude
    @Published var sawtoothWaveData: [Float] = []  // Triangle wave data for plotting
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        mic = input
        
        // Define a custom square waveform
        let sawtoothWaveform = Table(.sawtooth)
        
        // Use an Oscillator with the custom triangle waveform
        oscillator = Oscillator(waveform: sawtoothWaveform)
        oscillator.amplitude = 0.5  // Default amplitude, can be adjusted
        
        // Create a fader node to make the oscillator output silent
        silentNode = Fader(oscillator, gain: 0.0)  // Set gain to 0 to mute output
        
        // Set the silent node as the output of the audio engine
        engine.output = silentNode
        
        // Start pitch detection
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.pitch = pitch[0]  // Detected pitch (frequency)
                self.amplitude = amp[0]  // Detected amplitude
                self.updateSawtoothWave()
            }
        }
        
        // Attach a tap to capture the waveform data for visualization
        oscillator.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            let channelData = buffer.floatChannelData![0]  // Accessing the waveform data
            let frameLength = Int(buffer.frameLength)
            var waveData: [Float] = []
            
            for i in 0..<frameLength {
                waveData.append(channelData[i])
            }
            
            DispatchQueue.main.async {
                self.sawtoothWaveData = waveData  // Update the waveform data
            }
        }
        
        tracker.start()
    }
    
    func updateSawtoothWave() {
        // Set oscillator frequency to detected pitch
        oscillator.frequency = self.pitch
        // Set oscillator amplitude based on input amplitude
        oscillator.amplitude = self.amplitude
    }
    
    func start() {
        do {
            try engine.start()
            oscillator.start()
        } catch {
            print("Error starting the audio engine: \(error)")
        }
    }
    
    func stop() {
        engine.stop()
        oscillator.stop()
    }
}

struct SawtoothWavePlot: View {
    var sawtoothWaveData: [Float]  // Triangle wave data to plot
    var amplitudeScale: CGFloat    // Dynamically adjust height based on volume
    var widthScale: CGFloat        // Dynamically adjust width based on pitch
    var minAmplitudeThreshold: CGFloat = 0.01 // Threshold to flatten wave at low volume
    var minAmplitudeScale: CGFloat = 0.1      // Minimum wave height
    var minWidthScale: CGFloat = 0.5          // Minimum wave width
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                
                // Calculate step size based on widthScale
                let step = max((width / CGFloat(max(1, sawtoothWaveData.count))) * widthScale, minWidthScale)
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot triangle wave - linearly interpolate between peaks
                for i in 0..<sawtoothWaveData.count {
                    let x = CGFloat(i) * step
                    
                    // Scale the amplitude of the wave using effectiveAmplitudeScale
                    let y = (height / 2) - CGFloat(sawtoothWaveData[i]) * (height / 2) * amplitudeScale
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.red, lineWidth: 2)  // Use a distinctive color
        }
    }
}
