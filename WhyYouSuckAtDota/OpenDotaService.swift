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
        let account_id: Int?
        let hero_id: Int?
        let item_0: Int?
        let item_1: Int?
        let item_2: Int?
        let item_3: Int?
        let item_4: Int?
        let item_5: Int?
        let backpack_0: Int?
        let backpack_1: Int?
        let backpack_2: Int?
        let kills: Int?
        let deaths: Int?
        let assists: Int?
        let last_hits: Int?
        let denies: Int?
        let gold_per_min: Int?
        let xp_per_min: Int?
        let level: Int?
        let net_worth: Int?
        let aghanims_scepter: Int? //Bool
        let aghanims_shard: Int? //Bool
        let hero_damage: Int?
        let tower_damage: Int?
        let hero_healing: Int?
        let ability_upgrades_arr: [Int]?
        let start_time: Int?
        let duration: Int?
        let win: Int? //Bool
        let lose: Int? //Bool
        let total_gold: Int?
        let total_xp: Int?
//        let kills_per_min: Float?
//        let kda: Double?
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
    
    // API Calls
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
    // *****************************************
    
    // Get match ID numbers from RecentMatch structs
    func getRecentMatchIDs(recentMatches: [RecentMatch]) -> [Int]
    {
        var matchIDs: [Int] = []
        
        for recentMatch in recentMatches {
            matchIDs.append(recentMatch.match_id)
        }
        
        return matchIDs
    }
    
    // Get pro match ID numbers from ProMatch structs
    func getProMatchIDs(proMatches: [ProMatch]) -> [Int]
    {
        var matchIDs: [Int] = []
        
        for proMatch in proMatches {
            matchIDs.append(proMatch.match_id)
        }
        
        return matchIDs
    }
    
    // Get player match data for the selected player
    func getPlayerMatchData(matchIDs: [Int], accountID: Int) async throws -> [Player]
    {
        var matches: [Match] = []
        var playerData: [Player] = []
        
        // get all match objects for the selected player
        for matchID in matchIDs {
            matches.append(try await fetchMatch(matchId: matchID))
        }
        
        // get all player data objects for the selected player
        for match in matches {
            for player in match.players {
                if (player.account_id != nil && player.account_id == accountID) {
                    playerData.append(player)
                }
            }
        }
        return playerData
    }
    
    // Get pro player match data from 20 random pro matches
    func getProMatchData(matchIDs: [Int], accountID: Int) async throws -> [Player]
    {
        var matches: [Match] = []
        var proData: [Player] = []
        var count = 0
        
        // get first 20 pro match objects
        for matchID in matchIDs {
            if (count < 20) {
                matches.append(try await fetchMatch(matchId: matchID))
                print(count)
                count+=1
            }
            else {
                break
            }
                
        }
        // Get pro player data from the 20 matches
        for match in matches {
            for proPlayer in match.players {
                proData.append(proPlayer)
            }
        }
        return proData
    }
    
    // Get average GPM from multiple matches worth of player data
    func getAverageGPM(Data: [Player]) -> Int
    {
        var GPM = 0
        
        // Pull GPM from players recent match data
        for player in Data {
            GPM += player.gold_per_min ?? 0
        }
        // Find avg by dividing by number of matches
        GPM = GPM/Data.count
        
        return GPM
    }
}
