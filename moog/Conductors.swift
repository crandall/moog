//
//  Conductors.swift
//  moog
//
//  Created by Mike Crandall on 10/25/24.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import AVFoundation
import AVFAudio
import Foundation

enum WaveType {
    case sine, square, triangle, sawtooth, noise
}


class WaveConductor: ObservableObject {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    var tracker: PitchTap!
    var oscillator: Oscillator!
    var silentNode: Fader!
    var audioConverter: AVAudioConverter?  // AVAudioConverter for sample rate conversion
    let initialDevice: Device
    
    
    @Published var pitch: AUValue = 0.0  // Detected pitch
    @Published var amplitude: AUValue = 0.0  // Detected amplitude
    @Published var waveData: [Float] = []  // Wave data for plotting
    
    init() {
        // Audio Session Setup
        guard let input = engine.input else {
            fatalError("input not available")
        }
        
        guard let device = engine.inputDevice else { fatalError() }
        initialDevice = device
        
        mic = input
        
        // Set default waveform as sine and configure oscillator
        setupOscillator(waveform: .sine)
        

        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Set the category and activate the session
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setPreferredSampleRate(48000.0)  // Set input sample rate
            try audioSession.setActive(true)
            
            // Specify the preferred input if necessary (optional)
            if let availableInputs = audioSession.availableInputs {
                for input in availableInputs {
                    if input.portType == .headsetMic {  // Check for headphone mic input
                        try audioSession.setPreferredInput(input)
                        break
                    }
                }
            }
            
            print("Audio Session Sample Rate: \(audioSession.sampleRate)")
            
            // Safely unwrap the input format
            if let inputFormat = mic.avAudioNode.inputFormat(forBus: 0) as AVAudioFormat?,
               let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: inputFormat.channelCount) as AVAudioFormat?
            {
                // Set up AVAudioConverter for sample rate conversion
                audioConverter = AVAudioConverter(from: inputFormat, to: outputFormat)
                mic.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] (buffer, when) in
                    guard let strongSelf = self else { return }
                    strongSelf.processAudioBuffer(buffer: buffer, inputFormat: inputFormat, outputFormat: outputFormat)
                }
                
            } else {
                print("Failed to get valid input audio format")
            }
            
        } catch {
            print("Error setting up audio session: \(error)")
        }
        
        guard let input = engine.input else {
            fatalError("Microphone input not available")
        }
        
        // Start pitch detection
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.pitch = pitch[0]  // Detected pitch (frequency)
                self.amplitude = amp[0]  // Detected amplitude
                self.updateWave()
            }
        }
        tracker.start()
    }
    
    // This method is called every time a new audio buffer is captured from the microphone
    func processAudioBuffer(buffer: AVAudioPCMBuffer, inputFormat: AVAudioFormat, outputFormat: AVAudioFormat) {
        guard let converter = audioConverter else { return }
        
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: buffer.frameCapacity)!
        
        var error: NSError? = nil
        converter.convert(to: outputBuffer, error: &error) { inNumPackets, outStatus in
            // Provide input audio data to the converter
            outStatus.pointee = .haveData
            return buffer
        }
        
        if let error = error {
            print("Error during audio conversion: \(error)")
        } else {
            // Successfully converted the buffer, you can now use `outputBuffer`
            print("Successfully converted audio buffer")
            // Handle outputBuffer (e.g., send it to audio output, save to file, etc.)
        }
    }
    
    // Function to configure and replace the oscillator
    func setupOscillator(waveform: WaveType) {
        // Stop the current oscillator if it exists
        if let osc = oscillator {
            if engine.avEngine.isRunning {
                osc.avAudioNode.removeTap(onBus: 0)  // Ensure engine is running before removing taps
            }
            osc.stop()
        }
        
        // Choose the waveform based on the selected type
        let selectedWaveform: AudioKit.Table
        switch waveform {
        case .sine:
            selectedWaveform = AudioKit.Table(.sine)
        case .square:
            selectedWaveform = AudioKit.Table(.square)
        case .triangle:
            selectedWaveform = AudioKit.Table(.triangle)
        case .sawtooth:
            selectedWaveform = AudioKit.Table(.sawtooth)
        default:
            selectedWaveform = AudioKit.Table(.sine)
        }
        
        // Create a new oscillator with the selected waveform
        oscillator = Oscillator(waveform: selectedWaveform)
        oscillator.amplitude = 0.5  // Default amplitude
        
        // Recreate the silent node to mute output
        silentNode = Fader(oscillator, gain: 0.0)
        
        // Set silentNode as the engine's output directly
        engine.output = silentNode
        
        // Attach a tap to capture the waveform data for visualization
        oscillator.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            let channelData = buffer.floatChannelData![0]
            let frameLength = Int(buffer.frameLength)
            var data: [Float] = []
            
            for i in 0..<frameLength {
                data.append(channelData[i])
            }
            
            DispatchQueue.main.async {
                self.waveData = data  // Update the waveform data
            }
        }
        
        oscillator.start()
    }
    
    func updateWave() {
        oscillator.frequency = self.pitch
        oscillator.amplitude = self.amplitude
    }
    
    func start() {
        do {
            try engine.start()
            oscillator.start()
        } catch {
            print("Error starting the audio engine: \(error)")
        }
    }
    
    func stop() {
        engine.stop()
        oscillator.stop()
    }
    
}

class NoiseConductor: ObservableObject, HasAudioEngine {
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
        
        guard let device = engine.inputDevice else {
            fatalError()
        }
        
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
