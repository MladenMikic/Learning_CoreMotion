//
//  DevicePositionView.swift
//  Learning_CoreMotion
//
//  Created by Mladen Mikic on 17.06.2022.
//

import Foundation
import SwiftUI


public struct DevicePositionView: View {
        
    @ObservedObject var viewModel: MotionViewModel
    
    public var body: some View {
        // Pitch represents the device moving forward or backward.
        // 90 degrees pitch means the device is perfectly vertical, 0 pitch means the device is in placed on a horizontal surface (layed on the back).
        // Roll represents the device moving to the left and right.
        // 90 means the device is in horizontal orientation (layed down screen facing user), near 0 means its placed vertical.
        // Yaw represents the horizontal position based on the vertical center axis. Its the devices rotation in portrait.
        VStack {
            
            ZStack {
                
                Circle()
                    .fill(self.viewModel.pitchStateColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, self.viewModel.pitchValueModifier)
                   
                Image(systemName: viewModel.deviceImageName)
                    .resizable()
                    .frame(height: 64)
                    .frame(width: 44)
                    .scaledToFit()
                    .rotation3DEffect(.degrees(viewModel.correctedPitchValue), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(Double(viewModel.roll)), axis: (x: 0, y: 0, z: 1))
                
            }
            
            Ellipse()
                .fill(self.viewModel.rollStateColor)
                .frame(maxHeight: 10)
                .frame(width: 44 * self.viewModel.rollValueModifier)
                .padding(.top, 2.0)
           
        }
        
    }
}
