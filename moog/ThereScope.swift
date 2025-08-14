//
//  ThereScope.swift
//  moog
//
//  Created by Mike Crandall on 11/29/23.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFoundation
import AVFAudio


// Data Model for Scope
struct ThereScopeData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
}

struct ThereScopeView: View {
    @State private var selectedWave: WaveType = .sine
    @StateObject private var waveConductor = WaveConductor()
    @StateObject private var noiseConductor = NoiseConductor()
    @State private var amplitudeScale: CGFloat = 2.0    //2.0

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
                Button(action: {
                    selectedWave = .noise
                }) {
                    Text("Noise")
                        .padding()
                        .background(selectedWave == .noise ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 20)  // Space between buttons and plot
            
            // Display the waveform plot
            if selectedWave == .noise {
                RawOutputView1(noiseConductor.tappableNodeB,
                               strokeColor: Color.plotColor,
                               isNormalized: false,
                               scaleFactor: 10.0)
                
                
                
                .padding(.top, 20)   // Padding between the buttons and the plot
                .padding(.bottom, 20)   // Padding between the buttons and the plot
                .background(Color.black)
                .clipped()
            }else{
                WavePlot(
                    waveData: waveConductor.waveData,
                    amplitudeScale: amplitudeScale,  // Adjust as needed
                    widthScale: 0.25,      // Adjust as needed
                    minAmplitudeThreshold: 0.01,
                    minAmplitudeScale: 0.1,
                    minWidthScale: 0.5
                )
                .padding(.top, 20)   // Padding between the buttons and the plot
                .padding(.bottom, 20)   // Padding between the buttons and the plot
                .background(Color.black)
                .clipped()
                
            }
            
            Spacer()  // Spacer between the plot and text to push text to bottom
            
            HStack(alignment: .top) {
                // Frequency & Amplitude Labels
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency/Pitch:")
                        .font(.body)
                        .foregroundColor(.primary)
                    Text("Amplitude:")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .frame(width: 150, alignment: .leading)
                
                // Frequency & Amplitude Values
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(waveConductor.pitch, specifier: "%.1f") Hz")
                    Text("\(waveConductor.amplitude, specifier: "%.2f")")
                }
                .frame(width: 100, alignment: .leading)
                
                // Spacer between text and picker
                Spacer()
                
                // Centered Picker using a ZStack trick
                ZStack {
                    HStack { Spacer() }
                        .frame(maxWidth: .infinity)
                    
                    ThereScopeDevicePicker(device: waveConductor.initialDevice)
                }
                
                // Slider aligned at the top right
                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 8) {
                        Slider(value: $amplitudeScale, in: 0.1...3.001, step: 0.1)
                            .frame(width: UIScreen.main.bounds.width * 0.25)
                        
                        Text("\(amplitudeScale, specifier: "%.1f")")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .alignmentGuide(.top) { d in d[.top] }
                }

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

        }
        .onAppear {
            waveConductor.start()
            noiseConductor.start()
        }
        .onDisappear {
            waveConductor.stop()
            noiseConductor.stop()
        }
    }
}

struct WavePlot: View {
    var waveData: [Float]  // Triangle wave data to plot
    var amplitudeScale: CGFloat    // Dynamically adjust height based on volume
    var widthScale: CGFloat        // Dynamically adjust width based on pitch
    var minAmplitudeThreshold: CGFloat = 0.00 // Threshold to flatten wave at low volume
    var minAmplitudeScale: CGFloat = 0.0      // Minimum wave height
    var minWidthScale: CGFloat = 0.0      // Minimum wave width
    
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
            .stroke(Color.plotColor, lineWidth: 5)
        }
    }
}
