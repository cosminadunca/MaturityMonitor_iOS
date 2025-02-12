//
//  RequestGroupAccessView.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 11/09/2024.
//

import SwiftUI

struct RequestGroupAccessView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Access to presentation mode

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    
                    Text("Will be available soon...")
                        .font(Font.custom("Inter", size: 20))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.top) // Adjust to ignore top safe area
                .navigationBarBackButtonHidden(true) // Hide the default back button
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // Custom back button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Dismiss the view
                        }) {
                            HStack {
                                Image(systemName: "arrow.left") // Back arrow icon
                                    .foregroundColor(.black) // Set color to black
                                    .font(.font18)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    RequestGroupAccessView()
}
