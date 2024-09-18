//
//  TriangleWaveConductor.swift
//  moog
//
//  Created by Mike Crandall on 9/17/24.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFAudio

class MicInputToTriangleConductor: ObservableObject {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tracker: PitchTap!
    let oscillator: Oscillator  // Use a regular oscillator with a custom waveform (triangle)
    
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
        engine.output = oscillator
        
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

struct TriangleWavePlot1: View {
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

struct TriangleWavePlotView: View {
    @StateObject var conductor = MicInputToTriangleConductor()
    
    var body: some View {
        VStack {
            // Display pitch and amplitude
            Text("Pitch: \(conductor.pitch, specifier: "%.2f") Hz")
            Text("Amplitude: \(conductor.amplitude, specifier: "%.2f")")
            
            // Plot the triangle wave data
            if !conductor.triangleWaveData.isEmpty {
                TriangleWavePlot1(
                    triangleWaveData: conductor.triangleWaveData,
                    amplitudeScale: 1.0,  // Adjust as needed
                    widthScale: 1.0,      // Adjust as needed
                    minAmplitudeThreshold: 0.01,
                    minAmplitudeScale: 0.1,
                    minWidthScale: 0.5
                )
                .frame(height: 300)
                .background(Color.black)
            } else {
                Text("No data yet")
            }
            
            // Start and Stop buttons for controlling the engine
            HStack {
                Button("Start") {
                    conductor.start()
                }
                Button("Stop") {
                    conductor.stop()
                }
            }
        }
        .padding()
    }
}


// MARK: -- triangle
//class TriangleWaveMicConductor: ObservableObject, HasAudioEngine {
//    let engine = AudioEngine()
//    let mic: AudioEngine.InputNode
//    var tappableNode: Fader!
//    let silence: Fader
//    
//    @Published var triangleWaveBuffer: [Float] = []
//    @Published var amplitude: AUValue = 0.0 // Track the amplitude of the input
//    
//    init() {
//        guard let input = engine.input else {
//            fatalError("Microphone input not available")
//        }
//        
//        mic = input
//        tappableNode = Fader(mic)
//        silence = Fader(tappableNode, gain: 0) // No sound output
//        engine.output = silence
//    }
//    
//    func processAudio(buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData?[0] else { return }
//        let frameLength = Int(buffer.frameLength)
//        
//        var triangleWaveData: [Float] = []
//        var sumOfSquares: Float = 0.0
//        
//        for i in 0..<frameLength {
//            let sample = channelData[i]
//            // Convert sample to triangle wave: use absolute value to form the triangular shape
//            let triangleSample: Float = abs(sample) * 2 - 1
//            triangleWaveData.append(triangleSample)
//            
//            // Sum of squares for amplitude calculation
//            sumOfSquares += sample * sample
//        }
//        
//        // Calculate RMS amplitude (Root Mean Square)
//        let rmsAmplitude = sqrt(sumOfSquares / Float(frameLength))
//        
//        DispatchQueue.main.async {
//            self.triangleWaveBuffer = triangleWaveData
//            self.amplitude = rmsAmplitude // Update amplitude
//        }
//    }
//    
//    func start() {
//        do {
//            try engine.start()
//            mic.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
//                self.processAudio(buffer: buffer)
//            }
//        } catch {
//            print("Error starting audio engine: \(error)")
//        }
//    }
//    
//    func stop() {
//        mic.avAudioNode.removeTap(onBus: 0)
//        engine.stop()
//    }
//}
//
//struct TriangleWavePlot: View {
//    var triangleWaveData: [Float]
//    var amplitudeScale: CGFloat    // Dynamically adjust height based on volume
//    var widthScale: CGFloat        // Dynamically adjust width based on pitch
//    var minAmplitudeThreshold: CGFloat = 0.01 // Threshold to flatten wave at low volume
//    var minAmplitudeScale: CGFloat = 0.1      // Minimum wave height
//    var minWidthScale: CGFloat = 0.5          // Minimum wave width
//    var amplitudeMultiplier: CGFloat = 10.0   // Multiplier to enhance height responsiveness
//    var widthMultiplier: CGFloat = 5.0        // Multiplier to enhance width responsiveness
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Path { path in
//                let height = geometry.size.height
//                let width = geometry.size.width
//                
//                // Adjust step size based on frequency (pitch) and widthMultiplier
//                let step = max((width / CGFloat(max(1, triangleWaveData.count))) * widthScale * widthMultiplier, minWidthScale)
//                
//                // Adjust amplitude based on amplitudeMultiplier and ensure minimum scale
//                let effectiveAmplitudeScale = amplitudeScale < minAmplitudeThreshold ? 0 : max(amplitudeScale * amplitudeMultiplier, minAmplitudeScale)
//                
//                // Start drawing from the middle of the view
//                path.move(to: CGPoint(x: 0, y: height / 2))
//                
//                // Plot triangle wave - linearly interpolate between peaks
//                for i in 0..<triangleWaveData.count {
//                    let x = CGFloat(i) * step
//                    
//                    // Generate proper linear triangle wave between -1 and 1
//                    let absValue = abs(triangleWaveData[i]) // Absolute value for triangle shape
//                    let triangleValue = (2.0 * absValue - 1.0) // Linear ramp between -1 and 1
//                    
//                    // Calculate the y-position for the plot
//                    let centerY = height / 2  // Vertical center of the plot
//                    let amplitude = CGFloat(triangleValue) * (height / 2) * effectiveAmplitudeScale // Amplitude scaling
//                    let y = centerY - amplitude  // Final y-position
//                    
//                    path.addLine(to: CGPoint(x: x, y: y))
//                }
//            }
//            .stroke(Color.red, lineWidth: 2) // Set a different color for distinction
//        }
//    }
//}


