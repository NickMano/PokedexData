//
//  PokemonAPI.swift
//  Pokedex
//
//  Created by nicolas.e.manograsso on 02/03/2023.
//

import Foundation
import SwiftNetworking

enum PokemonAPI: Routable {
    static let baseURL = "https://pokeapi.co/api/v2/"
    static let manager = NetworkManager(baseURL: baseURL)
    
    case pokemons([Filters])
    case pokemon(String)
    case species(String)
    case types(String)
    case eggGroup(String)

    var path: String {
        switch self {
        case .pokemons: return "pokemon"
        case .pokemon(let pokemonName): return "pokemon/\(pokemonName)"
        case .species(let pokemonName): return "pokemon-species/\(pokemonName)"
        case .types(let name): return "type/\(name)"
        case .eggGroup(let name): return "egg-group/\(name)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .pokemons(let filters): return filters.map { $0.queryItem() }
        default: return nil
        }
    }

    var httpMethod: HttpMethod {
        switch self {
        default: return .get
        }
    }
}

enum Filters {
    case offset(Int)
    case limit(Int)
    
    func queryItem() -> URLQueryItem {
        switch self {
        case .offset(let off):
            return URLQueryItem(name: "offset", value: String(off))

        case .limit(let limit):
            return URLQueryItem(name: "limit", value: String(limit))
        }
    }
}
