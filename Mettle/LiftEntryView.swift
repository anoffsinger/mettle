//
//  LiftEntryView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import SwiftUI

struct LiftEntryView: View {



  let liftEntry: LiftEntry

    var body: some View {
      List {
        Text(liftEntry.weight.formattedWeight)
          .font(.system(size: 48, weight: .bold, design: .rounded))
          .navigationTitle(liftEntry.date.description)
          .navigationBarTitleDisplayMode(.inline)

        Section("Note", content: {
          Text("Really, really, close to nailing this one")
        })
      }

    }

}

#Preview {
  LiftEntryView(liftEntry: LiftEntry(liftType: .bench, date: Date(), weight: 1000000.00))
}
