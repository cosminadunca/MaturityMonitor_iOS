//
//  handleCSV.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 07/12/2024.
//

import Foundation

func cleanRows(file: String)-> String {
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    return cleanFile
}

func loadCSVData(fileName: String) -> [BetaValues] {
    var csvToStruct = [BetaValues]()
    
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("Error: file not found")
        return []
    }
    
    var data = ""
    do {
        data = try String(contentsOfFile: filePath)
    } catch {
        print(error)
        return []
    }
    
    data = cleanRows(file: data)
    
    var rows = data.components(separatedBy: "\n")
    rows.removeFirst() // Remove the header
    rows.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    for row in rows {
        let cleanedRow = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Ensure the row has enough elements and can be converted to BetaValues
        if let betaValues = BetaValues(raw: cleanedRow) {
            csvToStruct.append(betaValues)
        } else {
            print("Error: Failed to create BetaValues from row: \(cleanedRow)")
        }
    }
    
    return csvToStruct
}
