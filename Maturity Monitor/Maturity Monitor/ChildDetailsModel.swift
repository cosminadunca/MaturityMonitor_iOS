import SwiftUI

class ChildDetailsModel: ObservableObject {
    // Step 1 data
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var dateOfBirth: String = ""  // String to store formatted date
    @Published var selectedDate: Date = Date()  // Date object for the date picker

    // Step 2 data
    @Published var gender: Gender? = nil  // To store the gender: male || female
    @Published var image: UIImage? = nil  // Store the image in the model (UIImage)

    // Step 3 data
    @Published var momHeight: String = ""
    @Published var dadHeight: String = ""
    @Published var measurementType: MeasurementType? = nil // To store the measurement type: measured || estimated

    // Step 4 data
    @Published var country: String = ""
    @Published var ethnicity: String = ""
    @Published var primarySport: String = ""

    // Step 5 data
    @Published var agreeToResearch: Bool = false
}

enum Gender: String, CustomStringConvertible {
    case male = "Male"
    case female = "Female"
    
    var description: String { rawValue }
}

enum MeasurementType: String, CustomStringConvertible {
    case measured = "Measured"
    case estimated = "Estimated"
    
    var description: String { rawValue }
}

enum ApproveAIResearch: String, CustomStringConvertible {
    case yes = "Yes"
    case no = "No"
    
    var description: String { rawValue }
}

