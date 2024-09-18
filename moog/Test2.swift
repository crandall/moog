//
//  Test2.swift
//  moog
//
//  Created by Mike Crandall on 9/17/24.
//

import AVFoundation
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
}

struct ThereScopeView3: View {
    @State private var selectedWave: WaveConductor.WaveType = .sine
    @StateObject private var waveConductor = WaveConductor()
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10)  // Hardcoded space below the navigation bar
            
            // HStack for the buttons, with padding just below the navigation bar
            HStack {
                Button(action: {
                    selectedWave = .sine
                    waveConductor.setupOscillator(waveform: .sine)
                }) {
                    Text("Sine")
                        .padding()
                        .background(selectedWave == .sine ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    selectedWave = .square
                    waveConductor.setupOscillator(waveform: .square)
                }) {
                    Text("Square")
                        .padding()
                        .background(selectedWave == .square ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    selectedWave = .triangle
                    waveConductor.setupOscillator(waveform: .triangle)
                }) {
                    Text("Triangle")
                        .padding()
                        .background(selectedWave == .triangle ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    selectedWave = .sawtooth
                    waveConductor.setupOscillator(waveform: .sawtooth)
                }) {
                    Text("Sawtooth")
                        .padding()
                        .background(selectedWave == .sawtooth ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 20)  // Space between buttons and plot
            
            // Display the waveform plot
            WavePlot1(
                waveData: waveConductor.waveData,
                amplitudeScale: 2.0,  // Adjust as needed
                widthScale: 0.5,      // Adjust as needed
                minAmplitudeThreshold: 0.01,
                minAmplitudeScale: 0.1,
                minWidthScale: 0.5
            )
            .padding(.top, 20)   // Padding between the buttons and the plot
            .padding(.bottom, 20)   // Padding between the buttons and the plot
            .background(Color.black)
            
            Spacer()  // Spacer between the plot and text to push text to bottom
            
            // Text output showing frequency, amplitude, and scale
            HStack(alignment: .top, spacing: 0) {
                // First column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency/Pitch:")
                    Text("Amplitude:")
                }
                
                Spacer().frame(width: 40) // Fixed width of 40 pixels for the spacer
                
                // Second column - Direct access to values without Binding or unnecessary wrappers
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(waveConductor.pitch, specifier: "%.1f") Hz")  // Display the detected pitch
                    Text("\(waveConductor.amplitude, specifier: "%.2f")") // Display the detected amplitude
                }
                
                Spacer() // Additional spacer to push everything to the left
            }
            .padding(.horizontal, 20)  // Optional padding for horizontal alignment
            .padding(.bottom, 20)  // 20px space between the text and the bottom of the view
        }
        .onAppear {
            waveConductor.start()
        }
        .onDisappear {
            waveConductor.stop()
        }
    }
}

class WaveConductor1: ObservableObject {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tracker: PitchTap!
    var oscillator: Oscillator!
    var silentNode: Fader!
    
    @Published var pitch: AUValue = 0.0  // Detected pitch
    @Published var amplitude: AUValue = 0.0  // Detected amplitude
    @Published var waveData: [Float] = []  // Wave data for plotting
    
    enum WaveType {
        case sine, square, triangle, sawtooth
    }
    
    init() {
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        mic = input
        
        // Set default waveform as sine and configure oscillator
        setupOscillator(waveform: .sine)
        
        // Start pitch detection
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.pitch = pitch[0]  // Detected pitch (frequency)
                self.amplitude = amp[0]  // Detected amplitude
                self.updateWave()
            }
        }
        tracker.start()
    }
    
    // Function to configure and replace the oscillator
    func setupOscillator(waveform: WaveType) {
        // Stop the current oscillator if it exists
        if oscillator != nil {
            oscillator.stop()
            oscillator.avAudioNode.removeTap(onBus: 0)
        }
        
        // Choose the waveform based on the selected type
        var selectedWaveform: AudioKit.Table
        switch waveform {
        case .sine:
            selectedWaveform = AudioKit.Table(.sine)
        case .square:
            selectedWaveform = AudioKit.Table(.square)
        case .triangle:
            selectedWaveform = AudioKit.Table(.triangle)
        case .sawtooth:
            selectedWaveform = AudioKit.Table(.sawtooth)
        }
        
        // Create a new oscillator with the selected waveform
        oscillator = Oscillator(waveform: selectedWaveform)
        oscillator.amplitude = 0.5  // Default amplitude
        
        // Recreate the silent node to mute output
        silentNode = Fader(oscillator, gain: 0.0)
        engine.output = silentNode
        
        // Attach a tap to capture the waveform data for visualization
        oscillator.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            let channelData = buffer.floatChannelData![0]
            let frameLength = Int(buffer.frameLength)
            var data: [Float] = []
            
            for i in 0..<frameLength {
                data.append(channelData[i])
            }
            
            DispatchQueue.main.async {
                self.waveData = data  // Update the waveform data
            }
        }
        
        oscillator.start()
    }
    
    func updateWave() {
        oscillator.frequency = self.pitch
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

struct WavePlot1: View {
    var waveData: [Float]  // Triangle wave data to plot
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
                let step = max((width / CGFloat(max(1, waveData.count))) * widthScale, minWidthScale)
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot triangle wave - linearly interpolate between peaks
                for i in 0..<waveData.count {
                    let x = CGFloat(i) * step
                    
                    // Scale the amplitude of the wave using effectiveAmplitudeScale
                    let y = (height / 2) - CGFloat(waveData[i]) * (height / 2) * amplitudeScale
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.red, lineWidth: 2)  // Use a distinctive color
        }
    }
}
