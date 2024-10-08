//
//  AddWeightView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/9/24.
//

import SwiftUI

struct AddWeightView: View {
  let liftType: LiftType
  
  
  @State private var oldPR: Double = 0.0
  @State private var textFieldValue: String = ""
  @State private var continueButtonTapped: Bool = false
  @State private var showError: Bool = false
  @State private var kgViewEnabled: Bool
  @State private var weightIsPR: Bool = false
  @Binding var needsRefresh: Bool
  @Binding var addingPR: Bool
  
  private var displayedOldPR: Double {
      return kgViewEnabled ? poundsToKilograms(pounds: oldPR) : oldPR
  }
  
  @EnvironmentObject var settingsManager: SettingsManager
  @FocusState private var isTextFieldFocused: Bool
  
  public init(liftType: LiftType, needsRefresh: Binding<Bool>, addingPR: Binding<Bool>, kgViewEnabled: Bool) {
      self.liftType = liftType
      self._needsRefresh = needsRefresh
      self._addingPR = addingPR
      self._kgViewEnabled = State(initialValue: kgViewEnabled) // Initialize kgViewEnabled
    }
  
  var body: some View {
    VStack {
      VStack (spacing: -8) {
        ZStack {
          TextField(
            "",
            text: $textFieldValue
          )
          .frame(width: textFieldWidth(), alignment: .center)
          .keyboardType(.decimalPad)
          .font(.system(size: 90, weight: .semibold, design: .rounded))
          .foregroundColor(.clear)
          .overlay(
            LinearGradient(
              gradient: Gradient(colors: weightIsPR ? [Color(hex: "F91F60"), Color(hex: "EC1B80")] : [Color(hex: "e7e7e7"), Color(hex: "bfbfbf")]),
              startPoint: .top,
              endPoint: .bottom
            )
            .mask(
              Text(textFieldValue)
                .font(.system(size: 90, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
            )
          )
          .multilineTextAlignment(.center)
          .tint(.clear)
          .focused($isTextFieldFocused) // Bind focus state
      
          
          if textFieldValue.isEmpty {
            Text("0")
              .font(.system(size: 90, weight: .semibold, design: .rounded))
              .foregroundColor(Color(.clear))
              .frame(maxWidth: .infinity, alignment: .center)
              .overlay(
                LinearGradient(
                  gradient: Gradient(colors: weightIsPR ? [Color(hex: "F91F60"), Color(hex: "EC1B80")] : [Color(hex: "e7e7e7"), Color(hex: "bfbfbf")]),
                  startPoint: .top,
                  endPoint: .bottom
                )
                .mask(
                  Text("0")
                    .font(.system(size: 90, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                )
              )
          }
          Text(kgViewEnabled ? "kgs." : "lbs.")
            .font(.system(size: 32, weight: .semibold, design: .rounded))
            .foregroundColor(.clear)
            .overlay(
              LinearGradient(
                gradient: Gradient(colors: weightIsPR ? [Color(hex: "F91F60"), Color(hex: "EC1B80")] : [Color(hex: "e7e7e7"), Color(hex: "bfbfbf")]),
                startPoint: .top,
                endPoint: .bottom
              )
              .mask(
                Text(kgViewEnabled ? "kgs." : "lbs.")
                  .font(.system(size: 32, weight: .semibold, design: .rounded))
                  .multilineTextAlignment(.center)
              )
            )
            .offset(x: unitOffset(), y: 19)
          
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
        .onAppear {
          isTextFieldFocused = true // Automatically focus when view appears
          kgViewEnabled = settingsManager.displayInKilograms // initialize the unit setting
          fetchOldPR(for: liftType) { pr in
                  oldPR = pr
              }
        }
        .onChange(of: isTextFieldFocused) {
          if !isTextFieldFocused {
            isTextFieldFocused = true // Keep the TextField focused
          }
        }
        .onChange(of: textFieldValue) { newValue in
          if let value = Double(newValue), value > displayedOldPR {
                  weightIsPR = true
            print("Weight is a PR")
              } else {
                  weightIsPR = false
                print("Weight is not a PR")
              }
        }
        if showError {
          HStack (spacing: 4) {
            Text("Enter a weight greater than:")
              .font(.system(size: 16))
              .foregroundColor(.red)
            Text("\(formattedWeight(displayedOldPR)) \(kgViewEnabled ? "kg" : "lb")")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.red)
          }
        } else {
          HStack (spacing: 4) {
            Text("Last \(liftType.description) PR:")
              .font(.system(size: 16))
              .foregroundColor(Color("TextSecondary"))
            Text("\(formattedWeight(displayedOldPR)) \(kgViewEnabled ? "kg" : "lb")")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(Color("TextSecondary"))
          }
        }
      }
      .frame(maxHeight: .infinity)
      Button(action: {
        if let value = Double(textFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)), value > displayedOldPR {
          self.continueButtonTapped = true
          self.showError = false
          print("button tapped correctly")
        } else {
          self.showError = true
        }
      }) {
        Text("Continue")
          .font(.system(size: 17, weight: .bold))
          .foregroundColor(Color.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            LinearGradient(
              gradient: Gradient(
                colors: weightIsPR ? [Color(hex: "F91F60"), Color(hex: "EC1B80")] : [Color(hex: "e7e7e7"), Color(hex: "bfbfbf")] ),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .cornerRadius(20)
      }
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .inset(by: 1) // Adjust by half of the stroke line width
          .stroke(weightIsPR ? Color.black.opacity(0.1) : Color.black.opacity(0.02), lineWidth: 2)
      )
      // Hidden NavigationLink that triggers navigation
      NavigationLink(
          destination: AddNoteView(
              newPRWeight: kgViewEnabled ? kilogramsToPounds(kilograms: Double(textFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0) : Double(textFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0,
              needsRefresh: $needsRefresh,
              addingPR: $addingPR,
              liftType: liftType,
              oldPR: oldPR
          ),
          isActive: $continueButtonTapped
      ) {
          EmptyView()
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
    .navigationTitle("New \(liftType.description) PR")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Toggle(isOn: $kgViewEnabled) {
          Text("")
        }
        .toggleStyle(CustomToggleStyle())
      }
    }
  }
  
  private func textFieldWidth() -> CGFloat {
    let characterWidth: CGFloat = 60 // Adjust this value based on your font size
    if textFieldValue.count == 0 {
      return characterWidth
    } else {
      return CGFloat(textFieldValue.count) * characterWidth
    }
  }
  
  private func unitOffset() -> CGFloat {
    
    let characterWidth: CGFloat = 60
    
    if textFieldValue.count == 0 {
      return characterWidth
    } else if textFieldValue.count == 1 {
      return characterWidth
    } else if textFieldValue.count == 2 {
      return 90
    } else if textFieldValue.count == 3 {
      return 120
    } else {
      return 150
    }
  }
  
  private func fetchOldPR(for liftType: LiftType, completion: @escaping (Double) -> Void) {
      CloudKitManager.shared.fetchLiftEntries { result in
          switch result {
          case .success(let entries):
              let maxLift = entries.filter { $0.liftType == liftType }.max(by: { $0.weight < $1.weight })
              completion(maxLift?.weight ?? 0.0)
          case .failure(let error):
              print("Error fetching entries: \(error)")
              completion(0.0)
          }
      }
  }
  
  
}

#Preview {
  AddWeightView(
    liftType: .bench,
    needsRefresh: .constant(false),
    addingPR: .constant(false),
    kgViewEnabled: SettingsManager.shared.displayInKilograms
  )
    .environmentObject(SettingsManager.shared)
}

