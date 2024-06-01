//
//  AddNoteView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/19/24.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
  let newPRWeight: Double
  @State private var textFieldValue: String = ""
  @State private var finishButtonTapped: Bool = false
  @FocusState private var isTextFieldFocused: Bool
//    @Environment(\.dismiss) var dismiss
    @Binding var needsRefresh: Bool
    
    let liftType: LiftType
    let oldPR: Double

  var body: some View {
    VStack {
      ZStack {
        TextField(
          "Any notes to capture?",
          text: $textFieldValue
        )
        .keyboardType(.default)
        .foregroundColor(Color("Primary"))
        .multilineTextAlignment(.center)
        .tint(.pink)
        .focused($isTextFieldFocused) // Bind focus state
        if textFieldValue.isEmpty {
          Text("Any notes to capture?")
            .foregroundColor(Color("Secondary"))
            .frame(maxWidth: .infinity, alignment: .center)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .onAppear {
        isTextFieldFocused = true // Automatically focus when view appears
      }
      .onChange(of: isTextFieldFocused) {
        if !isTextFieldFocused {
          isTextFieldFocused = true // Keep the TextField focused
        }
      }
      Button(action: {
saveLiftEntryAndDismiss()
      }) {
        Text("Finish")
          .font(.system(size: 17, weight: .bold))
          .foregroundColor(Color.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            LinearGradient(
              gradient: Gradient(colors: [Color(hex: "F91F60"), Color(hex: "EC1B80")] ),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .cornerRadius(20)
      }
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .inset(by: 1) // Adjust by half of the stroke line width
          .stroke(Color.black.opacity(0.1), lineWidth: 2)
      )
      // Hidden NavigationLink that triggers navigation
      
    }
    .frame(maxHeight: .infinity)
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
    .navigationBarTitleDisplayMode(.inline)
//    .interactiveDismissDisabled(true)
    .navigationTitle("\(newPRWeight)")
  }
    
    private func saveLiftEntryAndDismiss() {
            let liftEntry = LiftEntry(liftType: .backSquat, date: Date(), weight: newPRWeight, note: textFieldValue)
            CloudKitManager.shared.saveLiftEntry(liftEntry) { result in
                switch result {
                case .success:
                    needsRefresh = true
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    print("Error saving entry: \(error)")
                }
            }
        }
}

#Preview {
    AddNoteView(newPRWeight: 225.0, needsRefresh: .constant(false), liftType: .bench, oldPR: 200.0)
}
