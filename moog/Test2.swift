//
//  Test2.swift
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

// Data Model for Scope
struct ThereScopeData3 {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var scale: CGFloat = 3.0
}

//// Conductor for Microphone Input with Pitch Tracking
//class ThereScopeConductor3: ObservableObject, HasAudioEngine {
//    @Published var data = ThereScopeData3()
//    @Published var gain: AUValue = 1.0
//    
//    let engine = AudioEngine()
//    let initialDevice: Device
//    
//    let mic: AudioEngine.InputNode
//    let tappableNodeA: Fader
//    let tappableNodeB: Fader
//    let tappableNodeC: Fader
//    let silence: Fader
//    
//    var tracker: PitchTap!
//    
//    init() {
//        guard let input = engine.input else { fatalError() }
//        
//        guard let device = engine.inputDevice else {
//            fatalError()
//        }
//        
//        initialDevice = device
//        
//        mic = input
//        tappableNodeA = Fader(mic)
//        tappableNodeB = Fader(tappableNodeA)
//        tappableNodeC = Fader(tappableNodeB)
//        silence = Fader(tappableNodeC, gain: 0)
//        engine.output = silence
//        
//        tracker = PitchTap(mic) { pitch, amp in
//            DispatchQueue.main.async {
//                self.update(pitch[0], amp[0])
//            }
//        }
//        tracker.start()
//    }
//    
//    func update(_ pitch: AUValue, _ amp: AUValue) {
//        // Reduces sensitivity to background noise
//        guard amp > 0.1 else { return }
//        
//        data.pitch = pitch
//        data.amplitude = amp
//        tappableNodeA.gain = gain
//    }
//    
//    func start() {
//        try? engine.start()
//    }
//    
//    func stop() {
//        engine.stop()
//    }
//}
//
//// Conductor for Processing Microphone Input into a Square Wave
//class SquareWaveMicConductor: ObservableObject, HasAudioEngine {
//    let engine = AudioEngine()
//    let mic: AudioEngine.InputNode
//    var tappableNode: Fader!
//    
//    @Published var squareWaveBuffer: [Float] = []
//    
//    init() {
//        guard let input = engine.input else {
//            fatalError("Microphone input not available")
//        }
//        
//        mic = input
//        tappableNode = Fader(mic)
//        
//        engine.output = tappableNode
//    }
//    
//    func processAudio(buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData?[0] else { return }
//        let frameLength = Int(buffer.frameLength)
//        
//        var squareWaveData: [Float] = []
//        
//        for i in 0..<frameLength {
//            let sample = channelData[i]
//            let squareSample: Float = sample > 0 ? 1.0 : -1.0
//            squareWaveData.append(squareSample)
//        }
//        
//        DispatchQueue.main.async {
//            self.squareWaveBuffer = squareWaveData
//        }
//    }
//    
//    func start() {
//        do {
//            // Start the audio engine
//            try engine.start()
//            
//            // Install the tap after the engine has started
//            tappableNode.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
//                self.processAudio(buffer: buffer)
//            }
//        } catch {
//            print("Error starting audio engine: \(error)")
//        }
//    }
//    
//    func stop() {
//        tappableNode.avAudioNode.removeTap(onBus: 0) // Always remove the tap when stopping
//        engine.stop()
//    }
//}

// Main View
struct ThereScopeView3: View {
    // Initialize the conductor you want to use here:
//    @StateObject var conductor = ThereScopeConductor3() // <-- Change this line to switch conductors
     @StateObject var conductor = SquareWaveMicConductor() // <-- Uncomment this line for Square Wave Conductor
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                // First column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency:")
                    Text("Amplitude:")
                    Text("Scale:")
                }
                
                Spacer().frame(width: 40)
                
                // Second column
                VStack(alignment: .leading, spacing: 8) {
                    if let conductor = conductor as? ThereScopeConductor3 {
                        Text("\(conductor.data.pitch, specifier: "%0.1f")")
                        Text("\(conductor.data.amplitude, specifier: "%0.1f")")
                    } else {
                        Text("N/A")
                        Text("N/A")
                    }
//                    Text("\(conductor.data.scale, specifier: "%0.1f")")
                }
                
                Spacer()
            }
            .padding()
            
            // Display the output depending on the conductor
            if let conductor = conductor as? ThereScopeConductor3 {
                RawOutputView1(conductor.tappableNodeB,
                               strokeColor: Color.plotColor,
                               isNormalized: false,
                               scaleFactor: conductor.data.scale)
                .clipped()
                .background(Color.black)
            } else if let squareWaveConductor = conductor as? SquareWaveMicConductor {
                SquareWavePlot(squareWaveData: squareWaveConductor.squareWaveBuffer)
                    .frame(height: 300)
                    .background(Color.black)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scale:")
                }
                
                Spacer().frame(width: 40)
                
//                Slider(value: $conductor.data.scale, in: 0.0...10.0)
//                    .frame(width: 300)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}

// Square Wave Plot for Visualization
struct SquareWavePlot: View {
    var squareWaveData: [Float]
    var amplitudeScale: CGFloat = 0.5 // Adjust this scale to control the wave height
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                let step = width / CGFloat(max(1, squareWaveData.count))
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot the square wave
                for i in 0..<squareWaveData.count {
                    let x = CGFloat(i) * step
                    // Scale the wave's amplitude to fit within the height
                    let y = (height / 2) - CGFloat(squareWaveData[i]) * (height / 2) * amplitudeScale
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }
}
struct SquareWavePlotx: View {
    var squareWaveData: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                let step = width / CGFloat(max(1, squareWaveData.count))
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for i in 0..<squareWaveData.count {
                    let x = CGFloat(i) * step
                    let y = (height / 2) - CGFloat(squareWaveData[i]) * (height / 2)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }
}
