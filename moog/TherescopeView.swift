//
//  TherescopeView.swift
//  moog
//
//  Created by Mike Crandall on 6/25/26.
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
struct TherescopeData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
}


struct TherescopeView: View {
    let sineOnly: Bool
    
    @State private var selectedWave: WaveType = .sine
    @StateObject private var waveConductor = WaveConductor()
    @StateObject private var noiseConductor = NoiseConductor()
    @State private var amplitudeScale: CGFloat = 4.0 / 3.0  // default to 4.0
    @State private var minAmplitudeScale: CGFloat = 0.5
    @State private var maxAmplitudeScale: CGFloat = 3.0
    @State private var noiseAmplitudeDefaultScale: CGFloat = 10.0
    
    
    private var amplitudeDisplayValue: Double {
        let minValue = Double(minAmplitudeScale)
        let maxValue = Double(maxAmplitudeScale)
        let currentValue = Double(amplitudeScale)
        
        guard maxValue > minValue else { return 1.0 }
        
        let normalized = (currentValue - minValue) / (maxValue - minValue)
        let mappedValue = 1.0 + normalized * 9.0
        return (mappedValue * 10).rounded() / 10
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            VStack {
                
                Spacer().frame(height: 20)  // Hardcoded space below the navigation bar
                
                // HStack for the buttons, with padding just below the navigation bar
                HStack(spacing: 20) {
                    waveButton("Sine", wave: .sine)
                    
                    if !sineOnly {
                        waveButton("Square", wave: .square)
                        waveButton("Triangle", wave: .triangle)
                        waveButton("Sawtooth", wave: .sawtooth)
                    }
                    
                    waveButton("Noise", wave: .noise)
                }
                
                .padding(.bottom, 10)  // Space between buttons and plot
                
                // Display the waveform plot
                if selectedWave == .noise {
                    RawOutputView1(noiseConductor.tappableNodeB,
                                   strokeColor: Color.plotColor,
                                   isNormalized: false,
                                   scaleFactor: (amplitudeScale / maxAmplitudeScale) * noiseAmplitudeDefaultScale
                    )
                    
                    
                    
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
                    
                    // LEFT: Frequency / Amplitude
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency/Pitch:")
                            Text("Amplitude:")
                        }
                        .frame(width: 150, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(waveConductor.pitch, specifier: "%.1f") Hz")
                            Text("\(waveConductor.amplitude, specifier: "%.2f")")
                        }
                        .frame(width: 100, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // CENTER: Slider
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Amplitude Scale: \(amplitudeDisplayValue, specifier: "%.1f")")
                                .monospacedDigit()
                            
                            Slider(value: $amplitudeScale,
                                   in: minAmplitudeScale...maxAmplitudeScale)
                            
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.20, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // RIGHT: Picker
                    ThereScopeDevicePicker(device: waveConductor.initialDevice)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
            }
            
            // Drawn on top of everything in the VStack
            informationOverlay
                .padding(.top, 100)
                .padding(.trailing, 30)
        }
        .modifier(IgnoreSafeAreaOnPhone())

        .onAppear {
            waveConductor.start()
            noiseConductor.start()
            
            print("sineOnly = \(sineOnly)")
        }
        .onDisappear {
            waveConductor.stop()
            noiseConductor.stop()
        }
    }

    enum WaveTypex {
        case sine, square, triangle, sawtooth, noise
    }
    
    private var informationOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Wave Information")
                .font(.headline)
            
            Text("Frequency: \(waveConductor.pitch, specifier: "%7.1f") Hz")
                .monospacedDigit()
            
            Text("Amplitude: \(waveConductor.amplitude, specifier: "%6.2f")")
                .monospacedDigit()
        }
        .frame(width: 220, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.5))
        )
        .foregroundStyle(.white)
    }

    private func waveButton(_ title: String, wave: WaveType) -> some View {
        Button(action: {
            selectedWave = wave
            
            switch wave {
            case .noise:
                break
            default:
                waveConductor.setupOscillator(waveform: wave)
            }
        }) {
            HStack(spacing: 8) {
                Text(title)
                
                Image(imageName(for: wave))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 24)
            }
            .padding(.horizontal, 8)
            .frame(height: 30)
            .background(selectedWave == wave ? Color.blue : Color.white)
            .foregroundColor(selectedWave == wave ? .white : .black)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
    }
    
    private func imageName(for wave: WaveType) -> String {
        switch wave {
        case .sine:     return "sineWave"
        case .square:   return "squareWave"
        case .triangle: return "triangleWave"
        case .sawtooth: return "sawtoothWave"
        case .noise:    return "noiseWave"
        }
    }
}

struct IgnoreSafeAreaOnPhone: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            content.ignoresSafeArea(.container, edges: .horizontal)
        } else {
            content
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
