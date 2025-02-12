//
//  CmConversion.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 16/12/2024.
//

import Foundation

struct CmConversion: Identifiable {
    let id: Double // centimeters
    let inches: Double
    
    init?(raw: [String]) {
        // Safely unwrap the values
        guard let id = Double(raw[0]),
              let inches = Double(raw[1]) else {
            print("Error: Invalid number format in raw data: \(raw)")
            return nil
        }
        
        self.id = id
        self.inches = inches
    }
}

// Parse the CSV data
func parseCSVData(rawData: String) -> [CmConversion] {
    var conversionData = [CmConversion]()
    
    let rows = rawData.components(separatedBy: "\n").dropFirst() // Drop the header row
    
    for row in rows {
        let cleanedRow = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if let cmConversion = CmConversion(raw: cleanedRow) {
            conversionData.append(cmConversion)
        } else {
            print("Error: Could not parse row: \(cleanedRow)")
        }
    }
    
    return conversionData
}
