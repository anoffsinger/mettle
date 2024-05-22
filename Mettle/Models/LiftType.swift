//
//  LiftType.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import Foundation

enum LiftType: CaseIterable {
  case backSquat
  case frontSquat
  case overHeadSquat

  case squatSnatch
  case powerSnatch
  case hangPowerSnatch

  case squatClean
  case powerClean
  case hangPowerClean

  case strictPress
  case pushPress
  case pushJerk
  case splitJerk

  case thruster
  case deadlift
  case bench

  var description: String {
    switch self {

    case .backSquat:
      return "Back Squat"
    case .frontSquat:
      return "Front Squat"
    case .overHeadSquat:
      return "Overhead Squat"

    case .squatSnatch:
      return "Squat Snatch"
    case .powerSnatch:
      return "Power Snatch"
    case .hangPowerSnatch:
      return "Hang Power Snatch"

    case .squatClean:
      return "Squat Clean"
    case .powerClean:
      return "Power Clean"
    case .hangPowerClean:
      return "Hang Power Clean"

    case .strictPress:
      return "Strict Press"
    case .pushPress:
      return "Push Press"
    case .pushJerk:
      return "Push Jerk"
    case .splitJerk:
      return "Split Jerk"

    case .thruster:
      return "Thruster"
    case .deadlift:
      return "Deadlift"
    case .bench:
      return "Bench"
    }
  }
}
