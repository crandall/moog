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

struct ThereScopeView3: View {
    // State to track the selected wave type
    @State private var selectedWave: WaveType = .square  // Default to square wave
    
    // Define an enumeration to represent the wave type
    enum WaveType {
        case sine
        case square
    }
    
    // Initialize the conductors for both wave types
    @StateObject private var sineWaveConductor = SineWaveMicConductor()
    @StateObject private var squareWaveConductor = SquareWaveMicConductor()
    
    var body: some View {
        VStack {
            // Buttons to switch between wave types
            HStack {
                Button(action: {
                    // Select the sine wave and stop the square wave conductor
                    selectedWave = .sine
                    squareWaveConductor.stop()
                    sineWaveConductor.start()
                }) {
                    Text("Sine")
                        .padding()
                        .background(selectedWave == .sine ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Select the square wave and stop the sine wave conductor
                    selectedWave = .square
                    sineWaveConductor.stop()
                    squareWaveConductor.start()
                }) {
                    Text("Square")
                        .padding()
                        .background(selectedWave == .square ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            // Display the output depending on the selected wave type
            if selectedWave == .sine {
                SineWavePlot(
                    sineWaveData: sineWaveConductor.sineWaveBuffer,  // Ensure passing array of [Float]
                    amplitudeScale: CGFloat(sineWaveConductor.amplitude), // Dynamically adjust height based on amplitude
                    widthScale: CGFloat(sineWaveConductor.amplitude),     // Dynamically adjust width based on pitch
                    minAmplitudeThreshold: 0.01,                 // Threshold for flattening the wave
                    minAmplitudeScale: 0.1,                      // Minimum height to prevent collapse
                    minWidthScale: 0.5                           // Minimum width to prevent collapse
                )
                .frame(height: 300)
                .background(Color.black)
                
            } else if selectedWave == .square {
                SquareWavePlot(
                    squareWaveData: squareWaveConductor.squareWaveBuffer,  // Ensure passing array of [Float]
                    amplitudeScale: CGFloat(squareWaveConductor.amplitude), // Dynamically adjust height based on amplitude
                    widthScale: CGFloat(squareWaveConductor.amplitude),     // Dynamically adjust width based on pitch
                    minAmplitudeThreshold: 0.01,                 // Threshold for flattening the wave
                    minAmplitudeScale: 0.1,                      // Minimum height to prevent collapse
                    minWidthScale: 0.5                           // Minimum width to prevent collapse
                )
                .frame(height: 300)
                .background(Color.black)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scale:")
                }
                Spacer().frame(width: 40)
            }
            .padding()
        }
        .onAppear {
            if selectedWave == .sine {
                sineWaveConductor.start()
            } else {
                squareWaveConductor.start()
            }
        }
        .onDisappear {
            sineWaveConductor.stop()
            squareWaveConductor.stop()
        }
    }
}


//struct ThereScopeView3: View {
//    // Initialize the conductor you want to use here:
////    @StateObject var conductor = SineWaveMicConductor() // <-- Change this line to switch conductors
//    @StateObject var conductor = SquareWaveMicConductor() // <-- Uncomment this line for Square Wave Conductor
//    
//    var body: some View {
//        VStack {
//            HStack(alignment: .top, spacing: 0) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Frequency:")
//                    Text("Amplitude:")
//                    Text("Scale:")
//                }
//                Spacer().frame(width: 40)
//            }
//            .padding()
//            
//            // Display the output depending on the conductor
//            if let sineWaveConductor = conductor as? SineWaveMicConductor {
//                SineWavePlot(
//                    sineWaveData: sineWaveConductor.sineWaveBuffer,  // Ensure passing array of [Float]
//                    amplitudeScale: CGFloat(sineWaveConductor.amplitude), // Dynamically adjust height based on amplitude
//                    widthScale: CGFloat(sineWaveConductor.amplitude),     // Dynamically adjust width based on pitch
//                    minAmplitudeThreshold: 0.01,                 // Threshold for flattening the wave
//                    minAmplitudeScale: 0.1,                      // Minimum height to prevent collapse
//                    minWidthScale: 0.5                           // Minimum width to prevent collapse
//                )
//                .frame(height: 300)
//                .background(Color.black)
//                
//            } else if let squareWaveConductor = conductor as? SquareWaveMicConductor {
//                SquareWavePlot(
//                    squareWaveData: squareWaveConductor.squareWaveBuffer,  // Ensure passing array of [Float]
//                    amplitudeScale: CGFloat(squareWaveConductor.amplitude), // Dynamically adjust height based on amplitude
//                    widthScale: CGFloat(squareWaveConductor.amplitude),     // Dynamically adjust width based on pitch
//                    minAmplitudeThreshold: 0.01,                 // Threshold for flattening the wave
//                    minAmplitudeScale: 0.1,                      // Minimum height to prevent collapse
//                    minWidthScale: 0.5                           // Minimum width to prevent collapse
//                )
//                .frame(height: 300)
//                .background(Color.black)
//            }
//            
//            HStack {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Scale:")
//                }
//                Spacer().frame(width: 40)
//            }
//            .padding()
//        }
//        .onAppear {
//            conductor.start()
//        }
//        .onDisappear {
//            conductor.stop()
//        }
//    }
//}
