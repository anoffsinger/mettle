//
//  HomeView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import SwiftUI
import Charts

struct ChartData: Identifiable {
  let id: UUID
  let liftType: LiftType
  let date: Date
  let weight: Double
}

struct HomeView: View {
  @State private var liftEntries: [LiftEntry] = []
  @State private var searchText = ""
  @State private var showSettingsModal = false
  @State var addingPR = false
  @State var viewingOverview = false
  @State var needsRefresh = false
  @EnvironmentObject var settingsManager: SettingsManager
  let weight: Double = 200.0 // Example weight
  @State private var isShowering = false
  @State private var showerTrigger = false  // New state to trigger animations
  let emojis = Array(repeating: "💪", count: 100)
  @State private var showWelcomeModal = false
  @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true // Track first launch
  
  
  @State private var showErrorAlert = false
  @State private var errorMessage = ""
  
  var body: some View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    
    NavigationView {
      ZStack {
        ScrollView {
          LazyVGrid(columns: columns, spacing: 8) {
            
            let filteredLiftEntries = liftEntries.filter { lift in
              searchText.isEmpty || lift.liftType.description.lowercased().contains(searchText.lowercased())
            }
            
            let groupedLiftEntries = Dictionary(grouping: filteredLiftEntries, by: { $0.liftType })
            
            ForEach(
              groupedLiftEntries.keys.sorted(by: {
                let date1 = groupedLiftEntries[$0]?.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
                let date2 = groupedLiftEntries[$1]?.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
                return date1 > date2
              }), id: \.self
            ) { liftType in
              if let specificLifts = groupedLiftEntries[liftType] {
                let maxWeightLift = specificLifts.max(by: { $0.weight < $1.weight })
                
                NavigationLink(
                  destination: LiftOverviewView(
                    liftType: liftType,
                    specificLifts: specificLifts,
                    maxWeightLift: maxWeightLift,
                    kgViewEnabled: settingsManager.displayInKilograms,
                    needsRefresh: $needsRefresh
                  )
                ) {
                  LiftTileView(liftType: liftType, specificLifts: specificLifts, maxWeightLift: maxWeightLift)
                }
                
              }
            }
          }
          .padding(.horizontal)
          Spacer()
            .frame(height: 88)
        }
        .background(Color("Background"))
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search your lifts")
        .toolbar {
          ToolbarItem(placement: .principal) {
            Button(action: triggerShower) {
              Image("Logo Header")
                .resizable()
                .frame(width: 32, height: 32)
                .offset(x: 2.5, y: -1)
            }
            .buttonStyle(PlainButtonStyle())
            .background(
              LinearGradient(
                stops: [
                  Gradient.Stop(color: Color(red: 1, green: 0.04, blue: 0.41), location: 0.00),
                  Gradient.Stop(color: Color(red: 0.84, green: 0.08, blue: 0.44), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
              )
            )
            .cornerRadius(10)
            .frame(width: 32, height: 32)
            .shadow(color: .black.opacity(0.2), radius: 2.5, x: 0, y: 2)
          }
          
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              showSettingsModal = true
            }) {
              Image(systemName: "gearshape.fill")
                .font(.system(size: 17))
              
                .foregroundColor(Color("TextPrimary"))
              
            }
          }
        }
        
        VStack {
          Spacer()
          HStack {
            Spacer()
            
            ButtonAddPR(addingPR: $addingPR, needsRefresh: $needsRefresh)
            
            
          }
          .padding(.trailing, 32)
        }
      }
      .overlay(
        EmojiShowerView(isShowering: $isShowering, emojis: emojis)
      )
      .navigationBarTitleDisplayMode(.inline)
    }
    
    
    .alert(isPresented: $showErrorAlert) {
      Alert(
        title: Text("Error"),
        message: Text(errorMessage),
        dismissButton: .default(Text("OK"))
      )
    }
    .accentColor(Color("Action"))
    
    .sheet(isPresented: $showSettingsModal) {
      // Replace with your modal view
      SettingsView()
    }
    .sheet(isPresented: $showWelcomeModal) {
      WelcomeView(showWelcomeModal: $showWelcomeModal)
                }
    .onAppear {
      fetchLiftEntries()
      if isFirstLaunch {
                          showWelcomeModal = true
                          isFirstLaunch = false // Mark the first launch as completed
                      }
    }
    .onChange(of: needsRefresh) { newValue in
      if newValue == true {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          fetchLiftEntries()
          needsRefresh = false
        }
      }
    }
  }
  
  private func fetchLiftEntries() {
    CloudKitManager.shared.fetchLiftEntries { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let entries):
          self.liftEntries = entries
          print("lift entries fetched")
          print(entries)
          
        case .failure(let error):
          self.errorMessage = error.localizedDescription
          self.showErrorAlert = true
          print("Error fetching entries: \(error)")
        }
      }
    }
  }
  
  private func sortLiftEntriesByDate(_ lifts: [LiftEntry]) -> [LiftEntry] {
    lifts.sorted { $0.date < $1.date }
  }
  private func triggerShower() {
    print("Logo tapped")
//    showerTrigger.toggle()  // Toggle to trigger a new animation
//    isShowering = true
//    
//    // Reset after animation duration
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {  // Slightly longer than animation duration
//      isShowering = false
//    }
  }
}

#Preview {
  HomeView()
    .environmentObject(SettingsManager.shared)
}

struct CustomToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
      Spacer()
      ZStack {
        Rectangle() // Custom switch background
          .frame(width: 80, height: 32)
          .foregroundColor(Color("ToggleBackground"))
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color(.white).opacity(0.5), lineWidth: 0.07)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 7)
              .frame(width: 36, height: 24)
              .foregroundColor(Color("ToggleForeground"))
              .offset(x: configuration.isOn ? 18 : -18)
              .animation(.spring(), value: configuration.isOn)
              .overlay(
                RoundedRectangle(cornerRadius: 7)
                  .stroke(Color(.white).opacity(0.5), lineWidth: 0.07)
                  .offset(x: configuration.isOn ? 18 : -18)
                  .animation(.spring(), value: configuration.isOn)
              )
          )
          .onTapGesture {
            configuration.isOn.toggle()
          }
        HStack(spacing: 0) {
          Text("Lb")
            .frame(width: 36, height: 24)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
          
          Text("Kg")
            .frame(width: 36, height: 24)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
        }
        .padding(.horizontal, 4)
      }
    }
  }
}



struct ButtonAddPR: View {
  @Binding var addingPR: Bool
  @Binding var needsRefresh: Bool
  
  var body: some View {
    Button(action: {
      addingPR = true
    }) {
      Image(systemName: "plus")
        .font(.system(size: 26, weight: .bold))
        .foregroundColor(Color.white)
        .frame(width: 80, height: 80)
        .background(
          LinearGradient(
            gradient: Gradient(colors: [Color(hex: "F91F60"), Color(hex: "EC1B80")]),
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .cornerRadius(40)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 40)
        .inset(by: 1) // Adjust by half of the stroke line width
        .stroke(Color("ButtonBorder"), lineWidth: 2)
    )
    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
    .sheet(isPresented: $addingPR) {
      AddPRView(addingPR: $addingPR, needsRefresh: $needsRefresh)
    }
  }
}

struct EmojiShowerView: View {
  @Binding var isShowering: Bool
  let emojis: [String]
  
  var body: some View {
    GeometryReader { geometry in
      ForEach(0..<emojis.count, id: \.self) { index in
        Text(emojis[index])
          .font(.system(size: 20))
          .opacity(opacity(for: index, in: geometry))
          .position(
            x: xPosition(for: index, in: geometry),
            y: yPosition(for: index, in: geometry)
          )
          .animation(
            Animation.timingCurve(0.2, 0.8, 0.8, 1, duration: 1)  // Custom easing for weighty feel
              .delay(Double(index) * 0.01)  // Slight delay between particles
              .repeatCount(1, autoreverses: false),
            value: isShowering
          )
      }
    }
    .allowsHitTesting(false)
  }
  
  private func xPosition(for index: Int, in geometry: GeometryProxy) -> CGFloat {
    isShowering ? CGFloat.random(in: 0...geometry.size.width) : geometry.size.width / 2
  }
  
  private func yPosition(for index: Int, in geometry: GeometryProxy) -> CGFloat {
    if isShowering {
      return geometry.size.height + 50  // Fall below screen
    } else {
      return -50  // Start above screen
    }
  }
  
  private func opacity(for index: Int, in geometry: GeometryProxy) -> Double {
    guard isShowering else { return 0 }
    
    let progress = Double(index) / Double(emojis.count)
    // Fade in quickly, maintain full opacity, then fade out
    if progress < 0.2 {
      return progress * 5  // Quick fade in
    } else if progress > 0.8 {
      return (1 - progress) * 5  // Quick fade out
    } else {
      return 1  // Full opacity in the middle
    }
  }
}







