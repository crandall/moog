//
//  SineWaveConductor.swift
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

// MARK: -- sine
class SineWaveMicConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tappableNode: Fader!
    let silence: Fader
    
    @Published var sineWaveBuffer: [Float] = []
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
        
        var sineWaveData: [Float] = []
        var sumOfSquares: Float = 0.0
        
        for i in 0..<frameLength {
            let sample = channelData[i]
            // Normalize the sample and create a sine wave representation
            let sineSample: Float = sin(sample * .pi * 2)
            sineWaveData.append(sineSample)
            
            // Sum of squares for amplitude calculation
            sumOfSquares += sample * sample
        }
        
        // Calculate RMS amplitude (Root Mean Square)
        let rmsAmplitude = sqrt(sumOfSquares / Float(frameLength))
        
        DispatchQueue.main.async {
            self.sineWaveBuffer = sineWaveData
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

struct SineWavePlot: View {
    var sineWaveData: [Float]
    var amplitudeScale: CGFloat   // Dynamically adjust height based on volume
    var widthScale: CGFloat       // Dynamically adjust width based on pitch
    var minAmplitudeThreshold: CGFloat = 0.01 // Threshold to flatten wave at low volume
    var minAmplitudeScale: CGFloat = 0.1  // Minimum wave height
    var minWidthScale: CGFloat = 0.5      // Minimum wave width
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                
                // Adjust step size based on frequency (pitch)
                let step = max((width / CGFloat(max(1, sineWaveData.count))) * widthScale, minWidthScale)
                
                // Check if amplitude is below the threshold and flatten the wave if so
                let effectiveAmplitudeScale = amplitudeScale < minAmplitudeThreshold ? 0 : max(amplitudeScale, minAmplitudeScale)
                
                // Start drawing from the middle of the view
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                // Plot sine wave
                for i in 0..<sineWaveData.count {
                    let x = CGFloat(i) * step
                    // Scale the amplitude of the wave using effectiveAmplitudeScale
                    let y = (height / 2) - CGFloat(sineWaveData[i]) * (height / 2) * effectiveAmplitudeScale
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 2) // Different color to distinguish from square wave
        }
    }
}

//// Conductor for Microphone Input with Pitch Tracking
//class SineWaveConductor: ObservableObject, HasAudioEngine {
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
//class SineOutputModel: ObservableObject {
//    @Environment(\.isPreview) var isPreview
//    @Published var data: [CGFloat] = []
//    var bufferSize: Int = 1024
//    var nodeTap: RawDataTap!
//    var node: Node?
//    
//    init() {
//        if isPreview {
//            mockAudioInput()
//        }
//    }
//    
//    func updateNode(_ node: Node, bufferSize: Int = 1024) {
//        if node !== self.node {
//            self.node = node
//            self.bufferSize = bufferSize
//            nodeTap = RawDataTap(node, bufferSize: UInt32(bufferSize), callbackQueue: .main) { rawAudioData in
//                self.updateData(rawAudioData.map { CGFloat($0) })
//            }
//            nodeTap.start()
//        }
//    }
//    
//    func updateData(_ data: [CGFloat]) {
//        self.data = data
//    }
//    
//    func mockAudioInput() {
//        var newData = [CGFloat]()
//        for _ in 0 ... 100 {
//            newData.append(CGFloat.random(in: -1.0 ... 1.0))
//        }
//        updateData(newData)
//        
//        let waitTime: TimeInterval = 0.1
//        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
//            self.mockAudioInput()
//        }
//    }
//}
//
//public struct SineOutputView: View {
//    @StateObject var rawOutputModel = SineOutputModel()
//    let strokeColor: Color
//    let isNormalized: Bool
//    let scaleFactor: CGFloat
//    let bufferSize: Int
//    var node: Node?
//    
//    public init(_ node: Node? = nil,
//                bufferSize: Int = 1024,
//                strokeColor: Color = Color.black,
//                isNormalized: Bool = false,
//                scaleFactor: CGFloat = 1.0)
//    {
//        self.node = node
//        self.bufferSize = bufferSize
//        self.strokeColor = strokeColor
//        self.isNormalized = isNormalized
//        self.scaleFactor = scaleFactor
//    }
//    
//    public var body: some View {
//        RawAudioPlot1(data: rawOutputModel.data, isNormalized: isNormalized, scaleFactor: scaleFactor)
//            .stroke(strokeColor, lineWidth: 5)
//            .onAppear {
//                if let node = node {
//                    rawOutputModel.updateNode(node)
//                }
//            }
//    }
//}
//
//struct SineAudioPlot: Shape {
//    var data: [CGFloat]
//    var isNormalized: Bool
//    var scaleFactor: CGFloat = 1.0
//    
//    func path(in rect: CGRect) -> Path {
//        var coordinates: [CGPoint] = []
//        
//        var rangeValue: CGFloat = 1.0
//        if isNormalized {
//            if let max = data.max() {
//                if let min = data.min() {
//                    rangeValue = abs(min) > max ? abs(min) : max
//                }
//            }
//        } else {
//            rangeValue = rangeValue / scaleFactor
//        }
//        
//        for index in 0 ..< data.count {
//            let x = index.mapped(from: 0 ... data.count, to: rect.minX ... rect.maxX)
//            let y = data[index].mappedInverted(from: -rangeValue ... rangeValue, to: rect.minY ... rect.maxY)
//            
//            coordinates.append(CGPoint(x: x, y: y))
//        }
//        
//        return Path { path in
//            path.addLines(coordinates)
//        }
//    }
//}
//
//struct SineOutputView_Previews: PreviewProvider {
//    static var previews: some View {
//        RawOutputView1()
//            .background(Color.white)
//    }
//}

