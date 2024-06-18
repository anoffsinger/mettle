//
//  LiftEntry.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import Foundation
import CloudKit

struct LiftEntry: Identifiable, Hashable {
  let id = UUID()
  let liftType: LiftType
  let date: Date
  let weight: Double
  let note: String?
  let recordID: CKRecord.ID?
  
  init(liftType: LiftType, date: Date, weight: Double, note: String?, recordID: CKRecord.ID? = nil) {
    self.liftType = liftType
    self.date = date
    self.weight = weight
    self.note = note
    self.recordID = recordID
  }
}
