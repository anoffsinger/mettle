//
//  LiftType.swift
//  Mettle
//
//  Created by Adam Noffsinger on 4/27/24.
//

import Foundation

enum LiftType: String, Codable, CaseIterable {
  case backSquat = "Back Squat"
  case frontSquat = "Front Squat"
  case overHeadSquat = "Overhead Squat"

  case squatSnatch = "Squat Snatch"
  case hangSquatSnatch = "Hang Squat Snatch"
  case powerSnatch = "Power Snatch"
  case hangPowerSnatch = "Hang Power Snatch"

  case squatClean = "Squat Clean"
  case hangSquatClean = "Hang Squat Clean"
  case powerClean = "Power Clean"
  case hangPowerClean = "Hang Power Clean"

  case strictPress = "Strict PRess"
  case pushPress = "Push Press"
  
  case pushJerk = "Push Jerk"
  case splitJerk = "Split Jerk"

  case thruster = "Thruster"
  
  case deadlift = "Deadlift"
  case sumoDeadlift = "Sumo Deadlift"
  
  case bench = "Bench"
  case dip = "Dip"
  case pullUp = "Pull Up"
  
  case cluster = "Cluster"
  case cleanAndJerk = "Clean and Jerk"
  
  case testLift = "Test Lift"

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
    case .hangSquatSnatch:
      return "Hang Squat Snatch"
    case .powerSnatch:
      return "Power Snatch"
    case .hangPowerSnatch:
      return "Hang Power Snatch"

    case .squatClean:
      return "Squat Clean"
    case .hangSquatClean:
      return "Hang Squat Clean"
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
    case .sumoDeadlift:
      return "Sumo Deadlift"
    
    case .bench:
      return "Bench"
    case .dip:
      return "Dip"
    case .pullUp:
      return "Pull Up"
      
    case .cluster:
      return "Cluster"
    case .cleanAndJerk:
      return "Clean and Jerk"
      
    case .testLift:
      return "Test Lift"
    }
  }
}
