//
//  MotionViewModel.swift
//  Learning_CoreMotion
//
//  Created by Mladen Mikic on 13.06.2022.
//

import Foundation
import CoreMotion
import SwiftUI

// Dont forget to add the Info.plist key:
// NSMotionUsageDescription
// https://developer.apple.com/documentation/bundleresources/information_property_list/nsmotionusagedescription

public class MotionViewModel: ObservableObject {
    
    private let motionMager = CMMotionManager()
    public var deviceImageName: String { UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone" }
    
    public private(set) var roll: Int = 0
    public private(set) var pitch: Int = 0
    public private(set) var yaw: Int = 0
    public private(set) var rawRoll: Double = 0.0
    public private(set) var rawPitch: Double = 0.0
    public private(set) var rawYaw: Double = 0.0
    public private(set) var correctedPitchValue: Double = 0
    public private(set) var pitchValueModifier: Double = 0
    
    public private(set) var pitchStateColor: Color = .green
    public private(set) var rollStateColor: Color = .green
    public private(set) var rollValueModifier: Double = 0
    private let allowedRollRange: Int
    
    // MARK: - Init.
    
    public init(allowedRollRange: Int) {
        
        self.allowedRollRange = allowedRollRange
        
        if self.motionMager.isDeviceMotionAvailable {
            
            self.motionMager.deviceMotionUpdateInterval = 0.1
            self.motionMager.showsDeviceMovementDisplay = true
            self.motionMager.startDeviceMotionUpdates(using: .xArbitraryZVertical,
                                                      to: OperationQueue(),
                                                      withHandler: { (data, error) in
                
                if let validData = data {
                    
                    DispatchQueue.global().async { [weak self] in
                        
                        guard let strongSelf = self else { return }
                        
                        // The correct way to access core motion data:
                        // https://stackoverflow.com/questions/9478630/get-pitch-yaw-roll-from-a-cmrotationmatrix
                        let quat = validData.attitude.quaternion
                        strongSelf.rawRoll = atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)
                        strongSelf.rawPitch = atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z)
                        strongSelf.rawYaw = asin(2*quat.x*quat.y + 2*quat.w*quat.z)
       
                        // Convert radian values to degrees.
                        strongSelf.roll = Int((strongSelf.rawRoll * 180) / .pi)
                        strongSelf.pitch = Int((strongSelf.rawPitch * 180) / .pi)
                        strongSelf.yaw = Int((strongSelf.rawYaw * 180) / .pi)
                        
                        // The correct pitch value is not 0, its 90 degrees.
                        strongSelf.correctedPitchValue = 90.0 - Double(strongSelf.pitch)
                           
                        // Rolling the device a little bit is allowed since the user wont be able to position it perfectly vertical.
                        let greenRollRange = -2...2
                        let orangeRollRange = -4...4
                        let redRollRange = -allowedRollRange...allowedRollRange
                        
                        if greenRollRange.contains(strongSelf.roll) {
                            strongSelf.rollStateColor = .green
                            strongSelf.rollValueModifier = 1.0
                        } else if orangeRollRange.contains(strongSelf.roll) {
                            strongSelf.rollStateColor = .orange
                            strongSelf.rollValueModifier = abs(Double(strongSelf.roll) * 1.1 / Double(allowedRollRange)) + 1.0
                        } else if redRollRange.contains(strongSelf.roll) {
                            strongSelf.rollStateColor = .red
                            let range = abs(Double(strongSelf.roll) * 0.5 / Double(allowedRollRange)) + 1.0
                            strongSelf.rollValueModifier = range
                        }
                        
                        let greenPitchRange = -6.0...1.0
                        let orangePitchRange = -9.0...3.0
                        var pitchValueModifier = 0.0
                        
                        if greenPitchRange.contains(strongSelf.correctedPitchValue) {
                            strongSelf.pitchStateColor = .green
                        } else if orangePitchRange.contains(strongSelf.correctedPitchValue) {
                            strongSelf.pitchStateColor = .orange
                            pitchValueModifier = abs(strongSelf.correctedPitchValue)
                        } else {
                            let correctedPitchValue = abs(strongSelf.correctedPitchValue)
                            if correctedPitchValue > 20 {
                                pitchValueModifier = 20.0
                            } else {
                                pitchValueModifier = correctedPitchValue
                            }
                            strongSelf.pitchStateColor = .red
                            
                        }
                        
                        if strongSelf.correctedPitchValue < 0 {
                            pitchValueModifier = pitchValueModifier * -1
                            strongSelf.pitchValueModifier = pitchValueModifier
                        } else {
                            strongSelf.pitchValueModifier = pitchValueModifier
                        }
                        
                        DispatchQueue.main.async { [weak strongSelf] in
                            withAnimation {
                                strongSelf?.objectWillChange.send()
                            }
                        }
                        
                    }
        
                }
             })
        } else {
            assertionFailure("Device Motion is not available.")
        }
    }
}
