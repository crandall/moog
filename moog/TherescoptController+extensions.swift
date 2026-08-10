//
//  TherescoptController+extensions.swift
//  moog
//
//  Created by Mike Crandall on 8/10/26.
//

import Foundation
import UIKit
import SwiftUI

extension TherescopeController {
    
    // MARK: - Hosted plot state
    final class HostedPlotState: ObservableObject {
        
        @Published var selectedWave: WaveType = .sine
        @Published var amplitudeScale: CGFloat = 4.0 / 3.0
        
        let minAmplitudeScale: CGFloat = 0.5
        let maxAmplitudeScale: CGFloat = 3.0
        let noiseAmplitudeDefaultScale: CGFloat = 10.0
        
        var noiseScaleFactor: CGFloat {
            guard maxAmplitudeScale > 0 else {
                return noiseAmplitudeDefaultScale
            }
            
            return (amplitudeScale / maxAmplitudeScale)
            * noiseAmplitudeDefaultScale
        }
        
        var amplitudeDisplayValue: Double {
            let minimum = Double(minAmplitudeScale)
            let maximum = Double(maxAmplitudeScale)
            let current = Double(amplitudeScale)
            
            guard maximum > minimum else {
                return 1.0
            }
            
            let normalized =
            (current - minimum) / (maximum - minimum)
            
            let mappedValue =
            1.0 + normalized * 9.0
            
            return (mappedValue * 10).rounded() / 10
        }
    }
    
    
    // MARK: - Single hosted SwiftUI plot
    
    struct HostedTherescopePlot: View {
        
        @ObservedObject var plotState: HostedPlotState
        @ObservedObject var waveConductor: WaveConductor
        @ObservedObject var noiseConductor: NoiseConductor
        
        var body: some View {
            Group {
                if plotState.selectedWave == .noise {
                    RawOutputView1(
                        noiseConductor.tappableNodeB,
                        strokeColor: Color.plotColor,
                        isNormalized: false,
                        scaleFactor: plotState.noiseScaleFactor
                    )
                } else {
                    WavePlot(
                        waveData: waveConductor.waveData,
                        amplitudeScale: plotState.amplitudeScale,
                        widthScale: 0.25,
                        minAmplitudeThreshold: 0.01,
                        minAmplitudeScale: 0.1,
                        minWidthScale: 0.5
                    )
                }
            }
            .background(Color.clear)
            .clipped()
        }
    }
}


