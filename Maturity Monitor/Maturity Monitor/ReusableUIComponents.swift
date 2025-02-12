// Rewrite this function to have less reusable components

import SwiftUI
import Combine
import PhotosUI

// Texts
struct CustomTextTitle: View { // Title with a shadow
    var title: String
    
    var body: some View {
        Text(title)
            .font(Font.custom("Inter-Regular", size: 30))
            .foregroundColor(.black)
            .shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 5)
            .padding(.top, 50)
    }
}

struct SimpleCustomTextTitle: View { // Title without shadow
    var title: String
    
    var body: some View {
        Text(title)
            .font(Font.custom("Inter-Regular", size: 30))
            .foregroundColor(.black)
            .padding(.top, 50)
    }
}

struct SimpleCustomText: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(Font.custom("Inter-Regular", size: 25))
            .foregroundColor(.black)
    }
}

struct ErrorCustomText: View { // Error message so displaying red
    var title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(.red)
            .font(Font.custom("Inter", size: 12))
            .padding(.bottom, 10)
    }
}

struct SuccessCustomText: View { // Success message so displaying green
    var title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(.green)
            .font(Font.custom("Inter", size: 12))
            .padding(.bottom, 10)
    }
}

//  Text Fields
struct SimpleCustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var characterLimit: Int = 30 // Set a default character limit of 30
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(Font.custom("Inter", size: 18))
            .foregroundColor(Color.black.opacity(0.60))
            .padding()
            .frame(width: 330, height: 50)
            .background(Color.white)
            .cornerRadius(10)
            .accentColor(Color("ButtonGreyLightStroke"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.8), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
            .padding(.bottom, 15)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .onChange(of: text) { newValue in
                if newValue.count > characterLimit {
                    text = String(newValue.prefix(characterLimit)) // Enforce character limit
                }
            }
    }
}

struct CustomTextField: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var characterLimit: Int = 50 // Set a default character limit of 30
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(Color("ButtonPurpleLight"))
                .frame(width: 20, height: 20)
                .padding(.leading, 10)
            
            Rectangle()
                .frame(width: 1, height: 30)
                .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80))
                .padding(.horizontal, 10)
            
            TextField(placeholder, text: $text)
                .padding(.leading, 5)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .accentColor(Color("ButtonGreyLightStroke"))
                .onChange(of: text) { newValue in
                    if newValue.count > characterLimit {
                        text = String(newValue.prefix(characterLimit)) // Enforce character limit
                    }
                }
        }
        .padding()
        .frame(width: 330, height: 50)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80), lineWidth: 0.5)
        )
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 4, y: 4)
    }
}

struct CustomPasswordField: View {
    var placeholder: String
    @Binding var text: String
    @State private var isPasswordVisible = false
    
    var body: some View {
        HStack {
            Image(systemName: "key")
                .foregroundColor(Color("ButtonPurpleLight"))
                .frame(width: 20, height: 20)
                .padding(.leading, 10)
            
            Rectangle()
                .frame(width: 1, height: 30)
                .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80))
                .padding(.horizontal, 10)
            
            if isPasswordVisible {
                TextField(placeholder, text: $text)
                    .padding(.leading, 5)
                    .autocapitalization(.none)
                    .accentColor(Color("ButtonGreyLightStroke"))
            } else {
                SecureField(placeholder, text: $text)
                    .padding(.leading, 5)
                    .autocapitalization(.none)
                    .accentColor(Color("ButtonGreyLightStroke"))
            }
            
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(Color("ButtonGreyLightStroke"))
            }
            
        }
        .padding()
        .frame(width: 330, height: 50)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80), lineWidth: 0.5)
        )
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 4, y: 4)
    }
}

struct CustomDateTextField: View {
    var placeholder: String = "DD/MM/YYYY"
    @Binding var dateText: String
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $dateText)
                .font(Font.custom("Inter", size: 18))
                .foregroundColor(Color.black.opacity(0.60))
                .padding(15)
                .accentColor(Color("ButtonGreyLightStroke"))
                .frame(width: 330, height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.8), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
                .keyboardType(.numberPad)
                .onChange(of: dateText, perform: formatDateInput)
            
            Button(action: {
                showDatePicker.toggle()
            }) {
                Image(systemName: "calendar")
                    .padding(12)
                    .foregroundColor(Color("ButtonPurpleLight"))
                    .font(.system(size: 20))
            }
            .padding(.trailing, 8)
        }
        .padding()
        .fullScreenCover(isPresented: $showDatePicker) {
            VStack {
                Spacer()
                Text("Select a date")
                    .font(Font.custom("Inter", size: 25))
                DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                Button(action: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    dateText = formatter.string(from: selectedDate)
                    showDatePicker.toggle()
                }) {
                    CustomButton(
                        title: "Confirm",
                        backgroundColor: Color("ButtonPurpleLight"),
                        textColor: .white
                    )
                }
                Spacer()
            }
        }
    }
    
    private func formatDateInput(_ value: String) {
        guard !value.isEmpty else {
            return // Do nothing if the input is empty
        }

        let digitsOnly = value.filter { $0.isNumber } // Only keep the digits
        
        switch digitsOnly.count {
        case 1...2:
            dateText = digitsOnly
        case 3...4:
            let day = digitsOnly.prefix(2)
            let month = digitsOnly.suffix(digitsOnly.count - 2)
            dateText = "\(day)/\(month)"
        case 5...8:
            let day = digitsOnly.prefix(2)
            let month = digitsOnly.dropFirst(2).prefix(2)
            let year = digitsOnly.dropFirst(4).prefix(4)
            dateText = "\(day)/\(month)/\(year)"
        default:
            let limitedDigits = String(digitsOnly.prefix(8))
            let day = limitedDigits.prefix(2)
            let month = limitedDigits.dropFirst(2).prefix(2)
            let year = limitedDigits.dropFirst(4)
            dateText = "\(day)/\(month)/\(year)"
        }
    }
}

// Buttons
struct CustomButton: View {
    var title: String
    var backgroundColor: Color
    var textColor: Color
    var width: CGFloat = 140
    var height: CGFloat = 35
    var fontSize: CGFloat = 15
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        Text(title)
            .font(Font.custom("Inter", size: fontSize))
            .foregroundColor(textColor)
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

struct CustomRegistrationButton: View {
    var title: String
    var iconName: String? = nil
    var backgroundColor: Color = Color(red: 0.88, green: 0.88, blue: 0.88)
    var textColor: Color = Color("ButtonTurquoiseMoreDark")
    var borderColor: Color = Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80)
    var shadowColor: Color = Color(red: 0, green: 0, blue: 0, opacity: 0.25)
    var width: CGFloat = 330
    var height: CGFloat = 55
    var cornerRadius: CGFloat = 12
    var fontSize: CGFloat = 18

    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .inset(by: 0.5)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .shadow(color: shadowColor, radius: 4, y: 4)
            .overlay(
                HStack {
                    if let icon = iconName {
                        Image(systemName: icon)
                            .foregroundColor(Color("ButtonTurquoiseDark"))
                            .font(.system(size: fontSize))
                    }
                    Text(title)
                        .font(Font.custom("Inter", size: fontSize))
                        .foregroundColor(textColor)
                }
            )
    }
}

// ProgressBar View
struct ProgressBar: View {
    var progressMultiplier: Int // Multiplier to determine progress (e.g., 1-5)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 10)
                    .foregroundColor(Color("ButtonGreyLight"))

                Rectangle()
                    .frame(width: geometry.size.width / 5 * CGFloat(progressMultiplier), height: 10)
                    .foregroundColor(Color("ButtonPurpleLight"))
            }
        }
        .frame(height: 10)
        .padding(.bottom, 10)
    }
}

// Checkbox
struct CustomCheckbox<Option: Hashable & CustomStringConvertible>: View {
    let options: [Option]
    @Binding var selectedOption: Option?
    var font: Font = Font.custom("Inter", size: 15)
    
    var body: some View {
        HStack(spacing: 50) { // Spacing between the options
            ForEach(options, id: \.self) { option in
                HStack {
                    Image(systemName: selectedOption == option ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(selectedOption == option ? .buttonPurpleLight : .gray)
                        .onTapGesture {
                            selectedOption = (selectedOption == option) ? nil : option
                        }
                    
                    Text(option.description)
                        .font(font)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center) // Center the content
    }
}

// Dorpdown
struct DropDownTextField: View {
    let label: String
    let placeholder: String
    let fieldWidth: CGFloat
    let units: [String]
    @Binding var text: String
    @Binding var selectedUnit: String
    @State private var isPickerOpen: Bool = false
    var isTextFieldDisabled: Bool = false

    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .font(Font.custom("Inter", size: 18))
                    .foregroundColor(.black)
                    .padding(.leading)
                Spacer(minLength: 0)
            }
            
            ZStack(alignment: .trailing) {
                TextField(
                    text.isEmpty ? placeholder : text,
                    text: $text
                )
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: fieldWidth)
                .accentColor(Color("ButtonGreyLightStroke")) // For typing bar
                .disabled(isTextFieldDisabled) // Disable typing into TextField
                .onReceive(Just(text)) { newValue in
                    // Apply text filtering only when isTextFieldDisabled is false
                    if !isTextFieldDisabled {
                        // Prevent entering letters and allow only valid double inputs
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        let components = filtered.components(separatedBy: ".")
                                    
                        // Allow only one decimal point
                        if components.count <= 2 {
                            text = filtered
                        }
                    }
                }
            
                Menu {
                    ForEach(units, id: \.self) { unit in
                        Button(action: {
                            selectedUnit = unit
                            if !isTextFieldDisabled {
                                text = unit
                            }
                        }) {
                            Text(unit)
                        }
                    }
                } label: {
                    Image(systemName: isPickerOpen ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(.buttonPurpleLight)
                        .font(.system(size: 20))
                }
                .frame(width: 40, height: 40)
            }
            .frame(width: fieldWidth + 60) // Adjust width to account for the dropdown icon
            .padding(.leading, -20)
        }
    }
}

// ImagePicker for selecting images from the photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}
