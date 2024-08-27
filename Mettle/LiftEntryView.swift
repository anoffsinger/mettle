//
//  LiftEntryView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import SwiftUI
import CloudKit

struct LiftEntryView: View {
  
  let liftEntry: LiftEntry
  @State private var showDeleteAlert = false
  @EnvironmentObject var settingsManager: SettingsManager
  @State private var kgViewEnabled: Bool
  @Environment(\.presentationMode) var presentationMode
  @Binding var needsRefresh: Bool
  
  public init(liftEntry: LiftEntry, kgViewEnabled: Bool, needsRefresh: Binding<Bool>) {
        self.liftEntry = liftEntry
        self._kgViewEnabled = State(initialValue: kgViewEnabled)
        self._needsRefresh = needsRefresh
      }
  
  var body: some View {
    List {
      Text(kgViewEnabled ? "\(formattedWeight(poundsToKilograms(pounds: liftEntry.weight ?? 0.0))) kg" : "\(formattedWeight(liftEntry.weight ?? 0.0)) lb")
        .font(.system(size: 48, weight: .bold, design: .rounded))
        .navigationTitle(liftEntry.liftType.description)
        .navigationBarTitleDisplayMode(.inline)
      
      Section(content: {
          Text("\(liftEntry.date, formatter: itemFormatter)")
      }, header: {
        HStack (spacing: 4) {
          
          Image(systemName: "calendar")
            .font(.system(size: 13.0, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
            .textCase(.none)
          Text("Date Added")
            .font(.system(size: 13.0, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
            .textCase(.none)
        }
        
          
          
      })
      
      Section(content: {
        Text(liftEntry.note ?? "No note added")
      }, header: {
        HStack (spacing: 4) {
          Image(systemName: "doc.text")
            .font(.system(size: 13.0, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
            .textCase(.none)
          Text("Note")
            .font(.system(size: 13.0, weight: .semibold))
            .foregroundColor(Color("TextPrimary"))
            .textCase(.none)
        }
          
          
      })
      
      Button(action: {
        showDeleteAlert = true
        
      }) {
        Text("Delete Entry")
          .foregroundColor(.red)
      }
      .alert(isPresented: $showDeleteAlert) {
        Alert(
          title: Text("Delete Entry"),
          message: Text("Are you sure you want to delete this entry?"),
          primaryButton: .destructive(Text("Delete")) {
            deleteLiftEntry(liftEntry)
          },
          secondaryButton: .cancel()
        )
      }
      
      
    }
    .onAppear {
      kgViewEnabled = settingsManager.displayInKilograms // initialize the unit setting
    }
    
  }
  private func deleteLiftEntry(_ liftEntry: LiftEntry) {
      CloudKitManager.shared.deleteLiftEntry(liftEntry) { result in
        switch result {
        case .success:
          DispatchQueue.main.async {
            needsRefresh = true
            presentationMode.wrappedValue.dismiss()
          }
          print("Lift entry deleted successfully")
        case .failure(let error):
          print("Error deleting lift entry: \(error)")
        }
      }
    }
}


#Preview {
  LiftEntryView(
    liftEntry: LiftEntry(
      liftType: .bench,
      date: Date(),
      weight: 1000000.00,
      note: "This one wasn't that tough.",
      recordID: CKRecord.ID(recordName: "exampleID")
    ),
    kgViewEnabled: SettingsManager.shared.displayInKilograms,
    needsRefresh: .constant(false)
  )
    .environmentObject(SettingsManager.shared)
}
