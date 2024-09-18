//
//  SquareWaveConductor.swift
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

// MARK: -- square
class SquareWaveMicConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tappableNode: Fader!
    let silence: Fader
    
    @Published var squareWaveBuffer: [Float] = []
    @Published var amplitude: AUValue = 0.0 // Track the amplitude of the input
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        
        mic = input
        tappableNode = Fader(mic)
        silence = Fader(tappableNode, gain: 0) // No sound output
        engine.output = silence
    }
    
    func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        var squareWaveData: [Float] = []
        var sumOfSquares: Float = 0.0
        
        for i in 0..<frameLength {
            let sample = channelData[i]
            let squareSample: Float = sample > 0 ? 1.0 : -1.0
            squareWaveData.append(squareSample)
            
            // Sum of squares for amplitude calculation
            sumOfSquares += sample * sample
        }
        
        // Calculate RMS amplitude (Root Mean Square)
        let rmsAmplitude = sqrt(sumOfSquares / Float(frameLength))
        
        DispatchQueue.main.async {
            self.squareWaveBuffer = squareWaveData
            self.amplitude = rmsAmplitude // Update amplitude
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

struct SquareWavePlot: View {
    var squareWaveData: [Float]
    var amplitudeScale: CGFloat   // Dynamically adjust height based on volume
    var widthScale: CGFloat       // Dynamically adjust width based on pitch
    var minAmplitudeThreshold: CGFloat = 0.01 // Threshold to flatten wave at low volume
    var minAmplitudeScale: CGFloat = 0.1      // Minimum wave height
    var minWidthScale: CGFloat = 0.5          // Minimum wave width
    var amplitudeMultiplier: CGFloat = 10.0   // Increase height scaling for minimal sound
    var widthMultiplier: CGFloat = 5.0        // Increase width scaling for minimal sound
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                
                // Adjust step size based on frequency (pitch)
                let step = max((width / CGFloat(max(1, squareWaveData.count))) * widthScale * widthMultiplier, minWidthScale)
                
                // Check if amplitude is below the threshold and flatten the wave if so
                let effectiveAmplitudeScale = amplitudeScale < minAmplitudeThreshold ? 0 : max(amplitudeScale * amplitudeMultiplier, minAmplitudeScale)
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot square wave
                for i in 0..<squareWaveData.count {
                    let x = CGFloat(i) * step
                    // Scale the amplitude of the wave using effectiveAmplitudeScale
                    let y = (height / 2) - CGFloat(squareWaveData[i]) * (height / 2) * effectiveAmplitudeScale
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}
