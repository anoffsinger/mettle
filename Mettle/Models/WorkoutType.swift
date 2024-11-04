//
//  WorkoutType.swift
//  Mettle
//
//  Created by Adam Noffsinger on 11/3/24.
//

import Foundation

enum WorkoutType: String, Codable, CaseIterable {
    case bradley = "Bradley"
    case dt = "DT"
    case glen = "Glen"
    case holbrook = "Holbrook"
    case klepto = "Klepto"
    case loredo = "Loredo"
    case manion = "Manion"
    case michael = "Michael"
    case murph = "Murph"
    case nate = "Nate"
    case randy = "Randy"
    case small = "Small"
    case theSeven = "The Seven"
    case tommyV = "Tommy V"
    case whitten = "Whitten"
    case annie = "Annie"
    case cindy = "Cindy"
    case diane = "Diane"
    case elizabeth = "Elizabeth"
    case eva = "Eva"
    case fran = "Fran"
    case grace = "Grace"
    case helen = "Helen"
    case isabel = "Isabel"
    case jackie = "Jackie"
    case karen = "Karen"
    case kelly = "Kelly"
    case nancy = "Nancy"

    var description: String {
        switch self {
        case .bradley: return "Bradley"
        case .dt: return "DT"
        case .glen: return "Glen"
        case .holbrook: return "Holbrook"
        case .klepto: return "Klepto"
        case .loredo: return "Loredo"
        case .manion: return "Manion"
        case .michael: return "Michael"
        case .murph: return "Murph"
        case .nate: return "Nate"
        case .randy: return "Randy"
        case .small: return "Small"
        case .theSeven: return "The Seven"
        case .tommyV: return "Tommy V"
        case .whitten: return "Whitten"
        case .annie: return "Annie"
        case .cindy: return "Cindy"
        case .diane: return "Diane"
        case .elizabeth: return "Elizabeth"
        case .eva: return "Eva"
        case .fran: return "Fran"
        case .grace: return "Grace"
        case .helen: return "Helen"
        case .isabel: return "Isabel"
        case .jackie: return "Jackie"
        case .karen: return "Karen"
        case .kelly: return "Kelly"
        case .nancy: return "Nancy"
        }
    }
}




