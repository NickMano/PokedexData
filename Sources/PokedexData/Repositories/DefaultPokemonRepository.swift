//
//  PokemonService.swift
//  Pokedex
//
//  Created by nicolas.e.manograsso on 13/12/2022.
//

import Foundation
import PokedexDomain

public struct DefaultPokemonRepository: PokemonRepository {
    public init() {}
    
    public func fetchPokemons() async throws -> [Pokemon] {
        let manager = PokemonAPI.manager
        let filters: [Filters] = [.limit(905)]
        let response = try await manager.sendRequest(route: PokemonAPI.pokemons(filters),
                                                     decodeTo: PokemonResponse.self)
        
        let results = try await fetchPokemons(response.pokemons)
        
        return results
    }

    public func fetchPokemonImage(_ url: String) async throws -> Data {
        let manager = PokemonAPI.manager
        
        return try await manager.fetchImageAsData(url)
    }
    
    public func fetchSpecies(_ identifier: Int) async throws -> PokedexDomain.PokemonSpecies {
        let manager = PokemonAPI.manager
        let response = try await manager.sendRequest(route: PokemonAPI.species("\(identifier)"),
                                                     decodeTo: PokemonSpecies.self)
        
        return response
    }
    
    public func fetchEggGroup(_ name: String) async throws -> EggGroup {
        let manager = PokemonAPI.manager
        let response = try await manager.sendRequest(route: PokemonAPI.eggGroup(name),
                                                     decodeTo: EggGroup.self)
        
        return response
    }
}

private extension DefaultPokemonRepository {
    func fetchPokemons(_ info: [NameUrl]) async throws -> [Pokemon] {
        try await withThrowingTaskGroup(of: Pokemon.self) { group in
            for pkm in info {
                group.addTask {
                    let pokemon = try await self.fetchPokemonDetail(name: pkm.name)
                    return pokemon
                }
            }
            
            var pokemons: [Pokemon] = []
            
            for try await pkm in group {
                pokemons.append(pkm)
            }
            
            return pokemons
        }
    }
    
    func fetchPokemonDetail(name: String) async throws -> Pokemon {
        let manager = PokemonAPI.manager
        let response = try await manager.sendRequest(route: PokemonAPI.pokemon(name),
                                                     decodeTo: Pokemon.self)
        
        return response
    }
}
