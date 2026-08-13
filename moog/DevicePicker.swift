//
//  ThereScopeDevicePicker.swift
//  moog
//
//  Created by Mike Crandall on 10/25/24.
//

import SwiftUI
import AudioKit

struct ThereScopeDevicePicker: View {
    
    @State private var selectedDevice: Device
    
    let devices: [Device]
    let onDeviceChanged: (Device) -> Void
    
    init(
        device: Device,
        devices: [Device],
        onDeviceChanged: @escaping (Device) -> Void
    ) {
        _selectedDevice = State(initialValue: device)
        self.devices = devices
        self.onDeviceChanged = onDeviceChanged
    }
    
    var body: some View {
        Picker(
            "Input: \(selectedDevice.deviceID)",
            selection: $selectedDevice
        ) {
            ForEach(devices, id: \.self) { device in
                Text(device.deviceID)
                    .tag(device)
            }
        }
        .pickerStyle(.menu)
        .foregroundColor(.black)
        .tint(.black)
        .onChange(of: selectedDevice) { newDevice in
            onDeviceChanged(newDevice)
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
//import AVFAudio
//
//
//struct ThereScopeDevicePicker: View {
//    @State var device: Device
//    
//    
//    
//    var body: some View {
//        Picker("Input: \(device.deviceID)", selection: $device) {
//            ForEach(getDevices(), id: \.self) {
//                Text($0.deviceID)
//            }
//        }
//        .pickerStyle(MenuPickerStyle())
//        .foregroundColor(.black)
//        .accentColor(.black)
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
