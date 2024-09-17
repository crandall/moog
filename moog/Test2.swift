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
