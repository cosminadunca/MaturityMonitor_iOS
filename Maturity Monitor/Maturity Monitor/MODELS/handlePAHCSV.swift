//
//  handlePAHCSV.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 12/12/2024.
//

import Foundation

func cleanRowsPAH(file: String)-> String {
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    return cleanFile
}

func loadCSVDataPAH(fileName: String) -> [agePAH] {
    var csvToStruct = [agePAH]()
    
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
    
    data = cleanRowsCmIn(file: data)
    
    var rows = data.components(separatedBy: "\n")
    rows.removeFirst()
    rows.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    for row in rows {
        let cleanedRow = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if let agePAH = agePAH(raw: cleanedRow) {  // Unwrapping the optional safely
            csvToStruct.append(agePAH)
        } else {
            print("Error: Failed to create BetaValues from row: \(cleanedRow)")
        }
    }
    
    return csvToStruct
}
