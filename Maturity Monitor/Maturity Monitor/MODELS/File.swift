//
//  File.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 17/12/2024.
//


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
