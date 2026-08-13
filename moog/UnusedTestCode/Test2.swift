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
import AVFoundation
import AVFAudio


// Data Model for Scope
//struct ThereScopeData {
//    var pitch: Float = 0.0
//    var amplitude: Float = 0.0
//}

struct TestView: View {
    @State private var selectedWave: WaveType = .sine
    @StateObject private var waveConductor = WaveConductor()
    @StateObject private var noiseConductor = NoiseConductor()
    
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
            } else {
                WavePlot(
                    waveData: waveConductor.waveData,
                    amplitudeScale: 2.0,  // Adjust as needed
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
            
            // Text output showing frequency, amplitude, and centered device picker
            HStack(alignment: .top) {
                // Fixed width column for Frequency and Amplitude values to prevent layout shift
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency/Pitch:")
                    Text("Amplitude:")
                }
                .frame(width: 150, alignment: .leading)  // Fixed width to prevent shifting
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(waveConductor.pitch, specifier: "%.1f") Hz")  // Display the detected pitch
                    Text("\(waveConductor.amplitude, specifier: "%.2f")") // Display the detected amplitude
                }
                .frame(width: 100, alignment: .leading)  // Fixed width to prevent shifting
                
                // Spacer to create flexible space between text and centered picker
                Spacer()
                
                // Centered Device Picker
//                ThereScopeDevicePicker(device: waveConductor.initialDevice)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 20)  // Optional padding for horizontal alignment
            .padding(.bottom, 20)  // 20px space between the text and the bottom of the view
            
        }
        .onAppear {
            waveConductor.start()
            noiseConductor.start()
            observeRouteChanges()  // Start observing audio route changes
        }
        .onDisappear {
            waveConductor.stop()
            noiseConductor.stop()
            NotificationCenter.default.removeObserver(self)  // Clean up observer
        }
    }
    
    // Function to start observing audio route changes
    func observeRouteChanges() {
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification,
                                               object: nil, queue: .main) { notification in
            handleRouteChange(notification: notification)
        }
    }
    
    // Function to handle the route change notification
    func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Log the reason for the route change
        print("Audio route changed: \(reason)")
        
        // Re-check available inputs
        let audioSession = AVAudioSession.sharedInstance()
        if let availableInputs = audioSession.availableInputs {
            for input in availableInputs {
                print("Available input: \(input.portName) - \(input.portType.rawValue)")
                
                // Optionally re-select a preferred input like a headset mic
                if input.portType == .headsetMic {
                    do {
                        try audioSession.setPreferredInput(input)
                        print("Headset microphone re-selected after route change.")
                    } catch {
                        print("Failed to select headset mic: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


class RawOutputModel2: ObservableObject {
    @Environment(\.isPreview) var isPreview
    @Published var data: [CGFloat] = []
    var bufferSize: Int = 1024
    var nodeTap: RawDataTap!
    var node: Node?
    
    init() {
        if isPreview {
            mockAudioInput()
        }
    }
    
    func updateNode(_ node: Node, bufferSize: Int = 1024) {
        if node !== self.node {
            self.node = node
            self.bufferSize = bufferSize
            nodeTap = RawDataTap(node, bufferSize: UInt32(bufferSize), callbackQueue: .main) { rawAudioData in
                self.updateData(rawAudioData.map { CGFloat($0) })
            }
            nodeTap.start()
        }
    }
    
    func updateData(_ data: [CGFloat]) {
        self.data = data
    }
    
    func mockAudioInput() {
        var newData = [CGFloat]()
        for _ in 0 ... 100 {
            newData.append(CGFloat.random(in: -1.0 ... 1.0))
        }
        updateData(newData)
        
        let waitTime: TimeInterval = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            self.mockAudioInput()
        }
    }
}

public struct RawOutputView2: View {
    @StateObject var rawOutputModel = RawOutputModel2()
    let strokeColor: Color
    let isNormalized: Bool
    let scaleFactor: CGFloat
    let bufferSize: Int
    var node: Node?
    
    public init(_ node: Node? = nil,
                bufferSize: Int = 1024,
                strokeColor: Color = Color.black,
                isNormalized: Bool = false,
                scaleFactor: CGFloat = 1.0)
    {
        self.node = node
        self.bufferSize = bufferSize
        self.strokeColor = strokeColor
        self.isNormalized = isNormalized
        self.scaleFactor = scaleFactor
    }
    
    public var body: some View {
        RawAudioPlot1(data: rawOutputModel.data, isNormalized: isNormalized, scaleFactor: scaleFactor)
            .stroke(strokeColor, lineWidth: 5)
            .onAppear {
                if let node = node {
                    rawOutputModel.updateNode(node)
                }
            }
    }
}

struct RawAudioPlotscaled2: Shape {
    var data: [CGFloat]
    var isNormalized: Bool
    var scaleFactor: CGFloat = 1.0
    var xScaleFactor: CGFloat = 0.25  // New x-axis scaling factor
    
    func path(in rect: CGRect) -> Path {
        var coordinates: [CGPoint] = []
        
        var rangeValue: CGFloat = 1.0
        if isNormalized {
            if let max = data.max() {
                if let min = data.min() {
                    rangeValue = abs(min) > max ? abs(min) : max
                }
            }
        } else {
            rangeValue = rangeValue / scaleFactor
        }
        
        // Apply the xScaleFactor to compress the waveform horizontally
        let scaledRectWidth = rect.width * xScaleFactor
        
        for index in 0 ..< data.count {
            let x = index.mapped(from: 0 ... data.count, to: rect.minX ... (rect.minX + scaledRectWidth))
            let y = data[index].mappedInverted(from: -rangeValue ... rangeValue, to: rect.minY ... rect.maxY)
            
            coordinates.append(CGPoint(x: x, y: y))
        }
        
        return Path { path in
            path.addLines(coordinates)
        }
    }
}

struct RawAudioPlot2: Shape {
    var data: [CGFloat]
    var isNormalized: Bool
    var scaleFactor: CGFloat = 1.0
    
    func path(in rect: CGRect) -> Path {
        var coordinates: [CGPoint] = []
        
        var rangeValue: CGFloat = 1.0
        if isNormalized {
            if let max = data.max() {
                if let min = data.min() {
                    rangeValue = abs(min) > max ? abs(min) : max
                }
            }
        } else {
            rangeValue = rangeValue / scaleFactor
        }
        
        for index in 0 ..< data.count {
            let x = index.mapped(from: 0 ... data.count, to: rect.minX ... rect.maxX)
            let y = data[index].mappedInverted(from: -rangeValue ... rangeValue, to: rect.minY ... rect.maxY)
            
            coordinates.append(CGPoint(x: x, y: y))
        }
        
        return Path { path in
            path.addLines(coordinates)
        }
    }
}

struct RawOutputView_Previews2: PreviewProvider {
    static var previews: some View {
        RawOutputView1()
            .background(Color.white)
    }
}
