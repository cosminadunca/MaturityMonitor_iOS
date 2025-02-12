//
//  handleCmCoversion.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 16/12/2024.
//

import Foundation

func cleanRowsCmIn(file: String)-> String {
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    return cleanFile
}

func loadCSVDataCmIn(fileName: String) -> [CmConversion] {
    var csvToStruct = [CmConversion]()
    
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
        
        if let CMConversion = CmConversion(raw: cleanedRow) {  // Unwrapping the optional safely
            csvToStruct.append(CMConversion)
        } else {
            print("Error: Failed to create BetaValues from row: \(cleanedRow)")
        }
    }
    
    return csvToStruct
}
