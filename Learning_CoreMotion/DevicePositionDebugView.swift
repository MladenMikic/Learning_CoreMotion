//
//  ContentView.swift
//  Learning_CoreMotion
//
//  Created by Mladen Mikic on 13.06.2022.
//

import SwiftUI

struct DevicePositionDebugView: View {
    
    @StateObject var viewModel = MotionViewModel(allowedRollRange: 44)
    
    var body: some View {
        // Pitch forward, backward
        // 90 pitch means its vertical, 0 pitch means the device is in placed on a horizontal surface
        // Roll is to the left and right.
        // 90 means the device is in horizontal orientation (layed down), near 0 means its placed vertical.
        // Yaw represents the horizontal position based on the vertical center axis.
        
        VStack {
            
            DevicePositionView(viewModel: viewModel)
           
            Text("pitch: \(viewModel.pitch)")
            Text("correctedPitchValue: \(viewModel.correctedPitchValue)")
            Text("rawPitch: \(viewModel.rawPitch)")
            Text("roll: \(viewModel.roll)")
            Text("rawRoll: \(viewModel.rawRoll)")
            Text("yaw: \(viewModel.yaw)")
            Text("rawYaw: \(viewModel.rawYaw)")
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DevicePositionDebugView()
    }
}
