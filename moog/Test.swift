//
//  Oscillator.swift
//  moog
//
//  Created by Mike Crandall on 10/18/23.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFoundation

struct ThereScopeData2 {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var scale: CGFloat = 3.0
}

class ThereScopeConductor2: ObservableObject, HasAudioEngine {
    @Published var data = ThereScopeData2()
    @Published var gain: AUValue = 1.0
    
    let engine = AudioEngine()
    var initialDevice: Device?
    
    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader
    
    var tracker: PitchTap!
    
    init() {
        guard let input = engine.input else { fatalError("Failed to get engine input") }
        
        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence
        
//        initialDevice = setExternalMicrophoneAsInput()
        
        tracker = PitchTap(mic) { [weak self] pitch, amp in
            DispatchQueue.main.async {
                self?.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }
    
    func setExternalMicrophoneAsInput() -> Device? {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
//            try session.setCategory(.playback)
            try session.setActive(true)
            
            if let availableInputs = session.availableInputs {
                for input in availableInputs {
                    if input.portType == .headsetMic {
                        try session.setPreferredInput(input)
                        print("Headset mic set as preferred input")
                        return AudioEngine.inputDevices.first { $0.name == input.portName }
                    }
                }
            }
        } catch {
            print("Error setting external microphone as input: \(error)")
        }
        return nil
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        guard amp > 0.1 else { return }
        
        data.pitch = pitch
        data.amplitude = amp
        
        tappableNodeA.gain = gain
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            print("Failed to start engine: \(error)")
        }
    }
    
    func stop() {
        engine.stop()
    }
}

struct ThereScopeView2: View {
    @StateObject var conductor = ThereScopeConductor2()
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency:")
                    Text("Amplitude:")
                    Text("Scale:")
                }
                
                Spacer().frame(width: 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(conductor.data.pitch, specifier: "%0.1f")")
                    Text("\(conductor.data.amplitude, specifier: "%0.1f")")
                    Text("\(conductor.data.scale, specifier: "%0.1f")")
                }
                
                Spacer()
            }
            .padding()
            
            RawOutputView1(conductor.tappableNodeB,
                           strokeColor: Color.plotColor,
                           isNormalized: false,
                           scaleFactor: conductor.data.scale)
            .clipped()
            .background(Color.black)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scale:")
                }
                
                Spacer().frame(width: 40)
                
                Text("\(conductor.data.scale, specifier: "%0.1f")")
                
                Spacer().frame(width: 40)
                
                Slider(value: $conductor.data.scale, in: 0.0...10.0).frame(width: 300)
                
                Spacer()
            }
            .padding()
            
            if let device = conductor.initialDevice {
                ThereScopeDevicePicker2(device: device)
            } else {
                Text("External microphone not available")
            }
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}

struct ThereScopeDevicePicker2: View {
    @State var device: Device
    
    var body: some View {
        Picker("Input: \(device.deviceID)", selection: $device) {
            ForEach(getDevices(), id: \.self) {
                Text($0.deviceID)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .foregroundColor(.black)
        .onChange(of: device, perform: setInputDevice)
    }
    
    func getDevices() -> [Device] {
        AudioEngine.inputDevices.compactMap { $0 }
    }
    
    func setInputDevice(to device: Device) {
        do {
            try AudioEngine.setInputDevice(device)
        } catch {
            print(error)
        }
    }
}

//import AudioKit
//import AudioKitEX
//import AudioKitUI
//import AudioToolbox
//import SoundpipeAudioKit
//import SwiftUI
//import AVFoundation
//
//struct ThereScopeData2 {
//    var pitch: Float = 0.0
//    var amplitude: Float = 0.0
//    var scale: CGFloat = 3.0
//}
//
//class ThereScopeConductor2: ObservableObject, HasAudioEngine {
//    @Published var data = ThereScopeData2()
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
//        guard let input = engine.input else { fatalError("Failed to get engine input") }
//        guard let device = engine.inputDevice else { fatalError("Failed to get input device") }
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
//        
//        setExternalMicrophoneAsInput()
//    }
//    
//    func setExternalMicrophoneAsInput() {
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
//            try session.setActive(true)
//            
//            let availableInputs = session.availableInputs
//            print("yo")
//            if let externalMic = availableInputs?.first(where: { $0.portType == .lineIn }) {
////            if let externalMic = availableInputs?.first(where: { $0.portType == .microphoneBuiltIn }) {
//                try session.setPreferredInput(externalMic)
//            }
//        } catch {
//            print("Error setting external microphone as input: \(error)")
//        }
//    }
//    
//    func update(_ pitch: AUValue, _ amp: AUValue) {
//        guard amp > 0.1 else { return }
//        
//        data.pitch = pitch
//        data.amplitude = amp
//        
//        tappableNodeA.gain = gain
//    }
//    
//    func start() {
//        do {
//            try engine.start()
//        } catch {
//            print("Failed to start engine: \(error)")
//        }
//    }
//    
//    func stop() {
//        engine.stop()
//    }
//}
//
//struct ThereScopeView2: View {
//    @StateObject var conductor = ThereScopeConductor2()
//    
//    var body: some View {
//        VStack {
//            HStack(alignment: .top, spacing: 0) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Frequency:")
//                    Text("Amplitude:")
//                    Text("Scale:")
//                }
//                
//                Spacer().frame(width: 40)
//                
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("\(conductor.data.pitch, specifier: "%0.1f")")
//                    Text("\(conductor.data.amplitude, specifier: "%0.1f")")
//                    Text("\(conductor.data.scale, specifier: "%0.1f")")
//                }
//                
//                Spacer()
//            }
//            .padding()
//            
//            RawOutputView1(conductor.tappableNodeB,
//                           strokeColor: Color.plotColor,
//                           isNormalized: false,
//                           scaleFactor: conductor.data.scale)
//            .clipped()
//            .background(Color.black)
//            
//            HStack {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Scale:")
//                }
//                
//                Spacer().frame(width: 40)
//                
//                Text("\(conductor.data.scale, specifier: "%0.1f")")
//                
//                Spacer().frame(width: 40)
//                
//                Slider(value: $conductor.data.scale, in: 0.0...10.0).frame(width: 300)
//                
//                Spacer()
//            }
//            .padding()
//            
//            ThereScopeDevicePicker2(device: conductor.initialDevice)
//        }
//        .onAppear {
//            conductor.start()
//        }
//        .onDisappear {
//            conductor.stop()
//        }
//    }
//}
//
//struct ThereScopeDevicePicker2: View {
//    @State var device: Device
//    
//    var body: some View {
//        Picker("Input: \(device.deviceID)", selection: $device) {
//            ForEach(getDevices(), id: \.self) {
//                Text($0.deviceID)
//            }
//        }
//        .pickerStyle(MenuPickerStyle())
//        .foregroundColor(.black)
//        .onChange(of: device, perform: setInputDevice)
//    }
//    
//    func getDevices() -> [Device] {
//        AudioEngine.inputDevices.compactMap { $0 }
//    }
//    
//    func setInputDevice(to device: Device) {
//        do {
//            try AudioEngine.setInputDevice(device)
//        } catch {
//            print(error)
//        }
//    }
//}
