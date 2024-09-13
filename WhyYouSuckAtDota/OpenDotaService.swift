//
//  OpenDotaService.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import Foundation
class OpenDotaService
{
    // Open Dota API call potential errors
    enum ApiError: Error {
        case invalidURL
        case invalidReponse
        case invalidData
    }
    
    // Open Dota API data objects
    // *****************************************
    struct Account: Codable
    {
        let profile: Profile
    }
    
    struct Profile: Codable
    {
        let account_id: Int
    }
    
    struct Player: Codable
    {
        let hero_id: Int
        let item_0: Int
        let item_1: Int
        let item_2: Int
        let item_3: Int
        let item_4: Int
        let item_5: Int
        let item_6: Int
        let backpack_0: Int
        let backpack_1: Int
        let backpack_2: Int
        let kills: Int
        let deaths: Int
        let assists: Int
        let last_hits: Int
        let denies: Int
        let gold_per_min: Int
        let xp_per_min: Int
        let level: Int
        let net_worth: Int
        let aghanims_scepter: Int? //Bool
        let aghanims_shard: Int? //Bool
        let hero_damage: Int
        let tower_damage: Int
        let hero_healing: Int
        let ability_upgrades_arr: [Int]
        let duration: Int
        let win: Int //Bool
        let lose: Int //Bool
        let total_gold: Int
        let total_xp: Int
        let kills_per_min: Float
        let kda: Int
    }
    
    struct SearchResult: Codable
    {
        let account_id: Int
        let personaname: String
        let avatarfull: String
    }
    
    struct Match: Codable
    {
        let players: [Player]
        let first_bood_time: Int
    }
    
    struct RecentMatch: Codable
    {
        let match_id: Int
    }
    
    struct ProMatch: Codable
    {
        let match_id: Int
        let radiant_team: [Int]
        let dire_team: [Int]
    }
    // *****************************************
    
    func openDotaAPICall(endpoint: String) async throws -> Data
    {
        // Create url for API call
        guard let url = URL(string: endpoint) else {
            throw ApiError.invalidURL
        }
        
        // make API call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Translate HTTP response from API call
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ApiError.invalidReponse
        }
        
        return data
    }
    
    func fetchAccount(accountID: Int) async throws -> Account
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/players/\(accountID)")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Account.self, from: data)
        } catch {
            throw ApiError.invalidData
        }
    }
    
    func fetchSearchResults(personaname: String) async throws -> [SearchResult]
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/search/?q=\(personaname)")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([SearchResult].self, from: data)
        } catch {
            throw ApiError.invalidData
        }
    }
    
    func fetchMatch(matchId: Int) async throws -> Match
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/matches/\(matchId)")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Match.self, from: data)
        } catch {
            throw ApiError.invalidData
        }
    }
    
    func fetchRecentMatches(accountId: Int) async throws -> [RecentMatch]
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/players/\(accountId)/recentMatches")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([RecentMatch].self, from: data)
        } catch {
            throw ApiError.invalidData
        }

    }
    
    func fetchProPubMatches() async throws -> [ProMatch]
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/publicMatches/?min_rank=81")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ProMatch].self, from: data)
        } catch {
            throw ApiError.invalidData
        }
    }
}
