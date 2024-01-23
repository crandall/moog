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

struct ThereScopeData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var scale: CGFloat = 3.0
}

class ThereScopeConductor: ObservableObject, HasAudioEngine {
    @Published var data = ThereScopeData()
    @Published var gain: AUValue = 1.0
    
    let engine = AudioEngine()
    let initialDevice: Device
    
    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader
    
    var tracker: PitchTap!
    
    init() {
        guard let input = engine.input else { fatalError() }
        
        guard let device = engine.inputDevice else { fatalError() }
        
        initialDevice = device
        
        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence
        
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.1 else { return }
        
        data.pitch = pitch
        data.amplitude = amp
        
        tappableNodeA.gain = gain
        
    }
}

struct ThereScopeView: View {
    @StateObject var conductor = ThereScopeConductor()
    
    var body: some View {
        
        VStack {
            
            HStack(alignment: .top, spacing: 0) {
                // First column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency:")
                    Text("Amplitude:")
                    Text("Scale:")
                }
                
                Spacer()
                    .frame(width: 40) // Fixed width of 40 pixels for the spacer
                
                // Second column
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(conductor.data.pitch, specifier: "%0.1f")")
                    Text("\(conductor.data.amplitude, specifier: "%0.1f")")
                    Text("\(conductor.data.scale, specifier: "%0.1f")")
                }
                
                Spacer() // Additional spacer to push everything to the left

            }
            .padding()
            

            RawOutputView1(conductor.tappableNodeB,
                          //                          bufferSize: 1024,
                          strokeColor: Color.plotColor,
                          isNormalized: false,
                          scaleFactor: conductor.data.scale) // Set your scale factor here
            .clipped()
            .background(Color.black)
            
            HStack() {
                // First column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scale:")
                }
                
                Spacer()
                    .frame(width: 40) // Fixed width of 40 pixels for the spacer
                
                // Second column
                Text("\(conductor.data.scale, specifier: "%0.1f")")
                
                // third column
                Spacer()
                    .frame(width:40)
                Slider(value: $conductor.data.scale, in: 0.0...10.0).frame(width: 300)
                
                Spacer() // Additional spacer to push everything to the left
                
            }
            .padding()

            
            ThereScopeDevicePicker(device: conductor.initialDevice)
            
            
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
    
}

struct ThereScopeDevicePicker: View {
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
        } catch let err {
            print(err)
        }
    }
}
