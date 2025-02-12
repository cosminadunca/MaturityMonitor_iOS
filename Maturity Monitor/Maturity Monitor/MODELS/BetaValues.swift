//
//  BetaValues.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 07/12/2024.
//

import Foundation

struct BetaValues: Identifiable {
    let id: Double
    let beta0: Double
    let beta1: Double
    let beta2: Double
    let beta3: Double
    
    init?(raw: [String]) {
        // Safely unwrap the values
        guard let id = Double(raw[0]),
              let beta0 = Double(raw[1]),
              let beta1 = Double(raw[2]),
              let beta2 = Double(raw[3]),
              let beta3 = Double(raw[4]) else {
            print("Error: Invalid number format in raw data: \(raw)")
            return nil
        }
        
        self.id = id
        self.beta0 = beta0
        self.beta1 = beta1
        self.beta2 = beta2
        self.beta3 = beta3
    }
}
