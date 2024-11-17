//
//  Commands.swift
//  Livelink
//
//  Created by Dominik Ruppin on 17.11.24.
//

enum Command {
    case profil
    case userlock
    case unknown

    init(commandString: String) {
        switch commandString.lowercased() {
        case "/profil":
            self = .profil
        case "/userlock":
            self = .userlock
        default:
            self = .unknown
        }
    }
}
