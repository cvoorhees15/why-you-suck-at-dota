//
//  OpenDotaService.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import Foundation
class OpenDotaService {
    
    // ********************
    // Open Dota API Calls
    // ********************
    
    // General API call used by all OpenDota fetchers
    func openDotaAPICall(endpoint: String) async throws -> Data
    {
        // Create url for API call
        guard let url = URL(string: endpoint) else {
            print("Error in openDotaAPICall()")
            throw ApiError.invalidURL
        }
        
        // Make API call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Translate HTTP response from API call
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            print("OpenDota API call response: \(response.statusCode)")
            throw ApiError.invalidReponse
        }
        
        return data
    }
    
    func fetchAccount(accountID: Int) async throws -> Account
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/players/\(accountID)?api_key=\(API_KEY ?? "")")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Account.self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchAccount()")
            throw ApiError.invalidData
        }
    }
    
    func fetchSearchResults(personaname: String) async throws -> [SearchResult]
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/search/?q=\(personaname)?api_key=\(API_KEY ?? "")")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([SearchResult].self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchSearchResults()")
            throw ApiError.invalidData
        }
    }
    
    func fetchMatch(matchId: Int) async throws -> Match
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/matches/\(matchId)?api_key=\(API_KEY ?? "")")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Match.self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchMatch()")
            throw ApiError.invalidData
        }
    }
    
    func fetchRecentMatches(accountId: Int) async throws -> [RecentMatch]
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/players/\(accountId)/recentMatches?api_key=\(API_KEY ?? "")")
        
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/publicMatches/?api_key=\(API_KEY ?? "")?min_rank=81")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ProMatch].self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchProPubMatches()")
            throw ApiError.invalidData
        }
    }
    
    func fetchDotaHeroes() async throws -> [Hero]
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/heroes?api_key=\(API_KEY ?? "")")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Hero].self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchDotaHeroes()")
            throw ApiError.invalidData
        }
    }
    
    // There is not an OpenDota API call for all items so grab them from a local json file (WhyYouSuckAtDota/Static Data/items.json)
    func fetchDotaItems() throws -> [Item]
    {
        if let url = Bundle.main.url(forResource: "items", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode([Item].self, from: data)
            } catch {
                print("Error in OpenDotaService::fetchDotaItems()")
                throw ApiError.invalidData
            }
        } else {
            print("Error in OpenDotaService::fetchDotaItems()")
            throw ApiError.invalidURL
        }
    }
    
    // Pull player match data for the selected player out of their recent matches
    func pullPlayerDataFromMatches(matchIDs: [Int], accountID: Int) async throws -> [Player]
    {
        var matches: [Match] = []
        var playerData: [Player] = []
        
        // If no match data received throw error
        if (matchIDs.isEmpty) {
            print("Error in pullPlayerDataFromMatches()")
            throw ApiError.noData
        }
        
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
    
    // Pull pro player match data out of 20 recent pro (immortal pub) matches
    func pullProDataFromMatches(matchIDs: [Int]) async throws -> [Player]
    {
        var matches: [Match] = []
        var proData: [Player] = []
        var count = 0
        
        // If no match data received throw error
        if (matchIDs.isEmpty) {
            print("Error in pullProDataFromMatches()")
            throw ApiError.noData
        }
        
        // Process match data
        for matchID in matchIDs {
            if (count < 20) {
                // Get first 20 pro match objects
                matches.append(try await fetchMatch(matchId: matchID))
                // Get all players from those matches
                proData.append(contentsOf: matches[count].players)
                count+=1
            }
            else {
                break
            }
        }

        return proData
    }
}
