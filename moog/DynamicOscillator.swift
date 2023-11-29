//import AudioKit
//import AudioKitEX
//import AudioKitUI
//import AudioToolbox
//import Keyboard
//import SoundpipeAudioKit
//import SwiftUI
//import Tonic
//
//class DynamicOscillatorConductor: ObservableObject, HasAudioEngine {
//    let engine = AudioEngine()
//
//
//    func noteOn(pitch: Pitch, point _: CGPoint) {
//        isPlaying = true
//        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
//    }
//
//    func noteOff(pitch _: Pitch) {
//        isPlaying = false
//    }
//
//    @Published var isPlaying: Bool = false {
//        didSet { isPlaying ? osc.start() : osc.stop() }
//    }
//
//    var osc = DynamicOscillator()
//
//    init() {
//        osc.amplitude = 0.2
//        engine.output = osc
//    }
//}
//
//struct DynamicOscillatorView: View {
//    @StateObject var conductor = DynamicOscillatorConductor()
//    @Environment(\.colorScheme) var colorScheme
//    @State private var selectedWaveform: String? = nil
//    @State private var nodeOutputColor: Color = Color(red: 66/255, green: 110/255, blue: 244/255, opacity: 1.0)
//
//    var body: some View {
//        VStack {
//            Text(conductor.isPlaying ? "STOP" : "START")
//                .foregroundColor(.blue)
//                .onTapGesture {
//                    conductor.isPlaying.toggle()
//                }
//            Spacer()
//            HStack {
//                Spacer()
//                Text("Sine")
//                    .foregroundColor(selectedWaveform == "sine" ? .blue : .black)
//                    .onTapGesture {
//                        conductor.osc.setWaveform(Table(.sine))
//                        selectedWaveform = "sine"
//                    }
//                Spacer()
//                Text("Square")
//                    .foregroundColor(selectedWaveform == "square" ? .blue : .black)
//                    .onTapGesture {
//                        conductor.osc.setWaveform(Table(.square))
//                        selectedWaveform = "square"
//                    }
//                Spacer()
//                Text("Triangle")
//                    .foregroundColor(selectedWaveform == "triangle" ? .blue : .black)
//                    .onTapGesture {
//                        conductor.osc.setWaveform(Table(.triangle))
//                        selectedWaveform = "triangle"
//                    }
//                Spacer()
//                Text("Sawtooth")
//                    .foregroundColor(selectedWaveform == "sawtooth" ? .blue : .black)
//                    .onTapGesture {
//                        conductor.osc.setWaveform(Table(.sawtooth))
//                        selectedWaveform = "sawtooth"
//                    }
//                Spacer()
//            }
//            Spacer()
//            HStack {
//                ForEach(conductor.osc.parameters) {
//                    ParameterRow(param: $0)
//                }
//            }
//            
//
//            NodeOutputView(conductor.osc, color: nodeOutputColor, backgroundColor: .black, bufferSize: 1024)
//            CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
//        }.cookbookNavBarTitle("Dynamic Oscillator")
//            .onAppear {
//                conductor.start()
//            }
//            .onDisappear {
//                conductor.stop()
//            }
//            .background(colorScheme == .dark ? Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
//    }
//}
