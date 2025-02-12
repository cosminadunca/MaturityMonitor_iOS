//
//  agePAH.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 12/12/2024.
//

import Foundation

struct agePAH: Identifiable {
    let id: Double
    let value: Double
    
    init?(raw: [String]) {
        // Safely unwrap the values
        guard let id = Double(raw[0]),
        let value = Double(raw[1]) else {
            print("Error: Invalid number format in raw data: \(raw)")
            return nil
        }
        
        self.id = id
        self.value = value
    }
}

// Parse the CSV data
func parseCSVData(rawData: String) -> [agePAH] {
    var conversionData = [agePAH]()
    
    let rows = rawData.components(separatedBy: "\n").dropFirst() // Drop the header row
    
    for row in rows {
        let cleanedRow = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if let agePAH = agePAH(raw: cleanedRow) {
            conversionData.append(agePAH)
        } else {
            print("Error: Could not parse row: \(cleanedRow)")
        }
    }
    
    return conversionData
}
