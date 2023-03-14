//
//  DefaultTypeRepository.swift
//  Pokedex
//
//  Created by nicolas.e.manograsso on 10/03/2023.
//

import Foundation
import PokedexDomain

public struct DefaultTypeRepository: TypeRepository {
    public init() {}
    
    public func getWeaknesses(typeNames: [String]) async throws -> TypeRelation {
        return try await withThrowingTaskGroup(of: TypeRelation.self) { group in
            for name in typeNames {
                group.addTask {
                    let response = try await self.fetchTypes(name)
                    return response.damageRelations
                }
            }
            
            var damageRelations: [TypeRelation] = []
            
            for try await typeOfPokemon in group {
                damageRelations.append(typeOfPokemon)
            }
            
            if damageRelations.count == 1, let typeRelation = damageRelations.first {
                return typeRelation
            }
            
            return mergeTypeRelations(damageRelations)
        }
    }
}

private extension DefaultTypeRepository {
    func mergeTypeRelations(_ typeRelations: [TypeRelation]) -> TypeRelation {
        let partialWeaknessess = typeRelations.flatMap { $0.doubleDamageFrom }
        let partialResistences = typeRelations.flatMap { $0.halfDamageFrom + $0.noDamageFrom }
        
        let halfDamageFrom = typeRelations.flatMap { $0.halfDamageFrom }
        let noDamageFrom = typeRelations.flatMap { $0.noDamageFrom }
        
        let weaknesses = partialWeaknessess.filter { !partialResistences.contains($0) }
        
        let typeRelation = TypeRelation(doubleDamageFrom: weaknesses,
                                        noDamageFrom: noDamageFrom,
                                        halfDamageFrom: halfDamageFrom)
        
        return typeRelation
    }
    
    func fetchTypes(_ name: String) async throws -> TypeResponse {
        let manager = PokemonAPI.manager
        let response = try await manager.sendRequest(route: PokemonAPI.types(name),
                                                     decodeTo: TypeResponse.self)
        
        return response
    }
}
