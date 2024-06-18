//
//  CloudKitManager.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/28/24.
//

import Foundation
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    private let publicDatabase = CKContainer(identifier: "iCloud.com.noff.Mettle").publicCloudDatabase

    func saveLiftEntry(_ liftEntry: LiftEntry, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let record = CKRecord(recordType: "LiftEntry")
        record["liftType"] = liftEntry.liftType.rawValue
        record["date"] = liftEntry.date
        record["weight"] = liftEntry.weight
        if let note = liftEntry.note {
            record["note"] = note
        }

        publicDatabase.save(record) { savedRecord, error in
            if let error = error {
                completion(.failure(error))
            } else if let savedRecord = savedRecord {
                completion(.success(savedRecord))
            }
        }
    }

    func fetchLiftEntries(completion: @escaping (Result<[LiftEntry], Error>) -> Void) {
        let query = CKQuery(recordType: "LiftEntry", predicate: NSPredicate(value: true))

        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(.failure(error))
            } else if let records = records {
                let liftEntries = records.compactMap { record -> LiftEntry? in
                    guard
                        let liftTypeRawValue = record["liftType"] as? String,
                        let liftType = LiftType(rawValue: liftTypeRawValue),
                        let date = record["date"] as? Date,
                        let weight = record["weight"] as? Double
                    else {
                        return nil
                    }
                    let note = record["note"] as? String
                    return LiftEntry(liftType: liftType, date: date, weight: weight, note: note, recordID: record.recordID)
                }
                completion(.success(liftEntries))
            }
        }
    }

    func deleteLiftEntry(_ liftEntry: LiftEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let recordID = liftEntry.recordID else {
            completion(.failure(NSError(domain: "CloudKitManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Record not found"])))
            return
        }

        publicDatabase.delete(withRecordID: recordID) { recordID, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
