//
//  Oscillator.swift
//  moog
//
//  Created by Mike Crandall on 10/18/23.
//

//import AudioKit
//import AudioKitEX
//import AudioKitUI
//import AudioToolbox
//import SoundpipeAudioKit
//import SwiftUI
//
//struct OscillatorData {
//    var pitch: Float = 0.0
//    var amplitude: Float = 0.0
//    var scale: CGFloat = 1.0
//}
//
//class OscillatorConductor: ObservableObject, HasAudioEngine {
//    @Published var data = OscillatorData()
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
//        guard let device = engine.inputDevice else { fatalError() }
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
//        // Reduces sensitivity to background noise to prevent random / fluctuating data.
//        guard amp > 0.1 else { return }
//        
//        data.pitch = pitch
//        data.amplitude = amp
//        
//        tappableNodeA.gain = gain
//
//    }
//}
//
//struct OscillatorView: View {
//    @StateObject var conductor = OscillatorConductor()
//    
//    var body: some View {
//        VStack {
//
//            Spacer()
//            Text("Oscillator")
//            RawOutputView(conductor.tappableNodeA,
//                          strokeColor: Color.plotColor)
//            .clipped()
//            .background(Color.black)
//
//            Text("Oscillator * 5.0")
//            RawOutputView(conductor.tappableNodeB,
//                          //                          bufferSize: 1024,
//                          strokeColor: Color.plotColor,
//                          isNormalized: false,
//                          scaleFactor: conductor.data.scale) // Set your scale factor here
//            .clipped()
//            .background(Color.black)
//
//            
//            HStack {
//                Text("Frequency")
//                Spacer()
//                Text("\(conductor.data.pitch, specifier: "%0.1f")")
//            }.padding()
//            
//            HStack {
//                Text("Amplitude")
//                Spacer()
//                Text("\(conductor.data.amplitude, specifier: "%0.1f")")
//            }.padding()
//            
//
//            HStack {
//                Text("Adjust the scale \(conductor.data.scale, specifier: "%0.1f")")
//                    .font(.subheadline)
//                
//                Slider(value: $conductor.data.scale, in: 0.0...10.0)
//            }.padding()
//
//            OscillatorDevicePicker(device: conductor.initialDevice)
//            
//            
//        }
//        .cookbookNavBarTitle("Tuner")
//        .onAppear {
//            conductor.start()
//        }
//        .onDisappear {
//            conductor.stop()
//        }
//    }
//
//}
//
//struct OscillatorDevicePicker: View {
//    @State var device: Device
//    
//    var body: some View {
//        Picker("Input: \(device.deviceID)", selection: $device) {
//            ForEach(getDevices(), id: \.self) {
//                Text($0.deviceID)
//            }
//        }
//        .pickerStyle(MenuPickerStyle())
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
//        } catch let err {
//            print(err)
//        }
//    }
//}
