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
            print("Endpoint: \(endpoint)")
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/publicMatches/?min_rank=81") // Using the api key with another param in the URL has proven problematic which is why it is not being used here
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ProMatch].self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchProPubMatches()")
            throw ApiError.invalidData
        }
    }
    
    func fetchMatchesByPlayerAndHero(heroId: Int, accountId: Int) async throws -> [ProMatch]
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/players/\(accountId)/matches/?hero_id=\(heroId)") // Using the api key with another param in the URL has proven problematic which is why it is not being used here
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ProMatch].self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchProPubMatches()")
            throw ApiError.invalidData
        }
    }
    
    func fetchHeroRankings(heroId: Int) async throws -> HeroRankings
    {
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/rankings/?hero_id=\(heroId)") // Using the api key with another param in the URL has proven problematic which is why it is not being used here
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(HeroRankings.self, from: data)
        } catch {
            print("Error in OpenDotaService::fetchTopRankPlayers()")
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
        var count = 0
        
        // If no match data received throw error
        if (matchIDs.isEmpty) {
            print("Error in OpenDotaService::pullPlayerDataFromMatches()")
            throw ApiError.noData
        }
        
        // get all match objects for the selected player
        for matchID in matchIDs {
            matches.append(try await fetchMatch(matchId: matchID))
            count += 1
            if (count == 20) {
                break
            }
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
    /*
     * Description: Pull pro match data for the provided set of pros
     * Input: An int Dictionary where each entry contains a hero and a high ranking player on that hero, KEY: account id, VALUE: hero id
     * Output: An Array of Player structs containing player data for one match
     */	
    func pullProDataFromMatches(topPlayersRecentMatches: Dictionary<Int, [Int]>) async throws -> [Player]
    {
        var matches: [Match] = []
        var playerData: [Player] = []
        
        if (topPlayersRecentMatches.isEmpty) {
            print("Error in OpenDotaService::pullProDataFromMatches()")
            throw ApiError.noData
        }
        
        for entry in topPlayersRecentMatches {
            for match in entry.value {
                // Assumes there should be up to 10 matches per entry
                do { matches.append(try await fetchMatch(matchId: match)) }
                // In cases where the API can't find a match, skip and continue to the next match
                catch ApiError.invalidReponse {continue}
            }
            for match in matches {
                for player in match.players {
                    if (player.account_id != nil && player.account_id == entry.key) {
                        playerData.append(player)
                    }
                }
            }
        }
        return playerData
    }
    
    // OLD FUNCTION USED TO COLLECT PRO DATA IN v1.0
    // Pull pro player match data out of 20 recent pro (immortal pub) matches
//    func pullProDataFromMatches(matchIDs: [Int]) async throws -> [Player]
//    {
//        var matches: [Match] = []
//        var proData: [Player] = []
//        var count = 0
//        
//        // If no match data received throw error
//        if (matchIDs.isEmpty) {
//            print("Error in OpenDotaService::pullProDataFromMatches()")
//            throw ApiError.noData
//        }
//        
//        // Process match data
//        for matchID in matchIDs {
//            if (count < 20) {
//                // Get first 20 pro match objects
//                matches.append(try await fetchMatch(matchId: matchID))
//                // Get all players from those matches
//                proData.append(contentsOf: matches[count].players)
//                count+=1
//            }
//            else {
//                break
//            }
//        }
//
//        return proData
//    }
    
    /* 
     * Description: Get the account ids for the top players on specific heroes
     * Input: An int Array containing 3 hero ids (should be selected players most played heroes in their recent matches)
     * Output: An int Dictionary where each entry contains a hero and a high ranking player on that hero, KEY: account id, VALUE: hero id
     */
    func pullTopRankPlayersForHeroes(heroIDs: [Int]) async throws -> Dictionary<Int, Int>
    {
        var topRankedPlayers: HeroRankings
        var topPlayersForHeroes: Dictionary<Int, Int> = [:] // key: account id, value: hero
        var testContainer: [ProMatch] = []
        var count: Int = 0
        
        // Loop through each hero
        for id in heroIDs {
            // API call that gets list of top ranked players for a hero
            topRankedPlayers = try await fetchHeroRankings(heroId: id)
            
            // If data was not received get out
            if (topRankedPlayers.rankings.isEmpty) {
                print("Error in OpenDotaService::pullTopRankPlayersForHeroes(), provided hero id likely does not exist")
                throw ApiError.noData
            }
            // Loop through top ranked players on a specific hero
            for player in topRankedPlayers.rankings {
                // Grab the account id for a top ranked player
                topPlayersForHeroes.updateValue(topRankedPlayers.hero_id, forKey: player.account_id)
                // Test if there is match data available for that account, if not loop back and grab a different top ranked player
                testContainer = try await fetchMatchesByPlayerAndHero(heroId: id, accountId: player.account_id)
                if (!testContainer.isEmpty) {
                    break
                }
            }
            count += 1
            
            // Break loop once we have a top ranked player for all 3 heroes
            if (count == 3) {
                break
            }
        }
        return topPlayersForHeroes
    }
    
    /*
     * Description: Get up to 10 matches where a specified account is playing a specified hero
     * Input: An int Dictionary where each entry contains a hero and a high ranking player on that hero, KEY: account id, VALUE: hero id
     * Output: An int Dictionary where each entry contains a player and an array of their latest 10 matches on a specific hero, KEY: account id, VALUE: array of match ids
     */
    func pullMatchesForPlayerOnHero(topPlayersForHeroes: Dictionary<Int, Int>) async throws -> Dictionary<Int, [Int]>
    {
        var matchBuffer: [ProMatch] = []
        var matchIdBuffer: [Int] = []
        var topPlayersRecentMatches: Dictionary<Int, [Int]> = [:]
        var count: Int = 0
        
        // Loop through each top ranked player
        for player in topPlayersForHeroes {
            // API call to fetch all matches for a player playing a specified hero
            matchBuffer = try await fetchMatchesByPlayerAndHero(heroId: player.value, accountId: player.key)
            
            // If data was not received for the current player, skip to the next one
            if (matchBuffer.isEmpty) {
                print("Warning in OpenDotaService::pullMatchesForPlayerOnHero(), no matches for a specified player and hero, skipping to the next high ranked player for this hero: \(player.value)")
                count = 0
                matchIdBuffer.removeAll()
                continue
            }
            else {
                // Loop through matches where player is playing the specified hero
                for match in matchBuffer {
                    // Grab a match
                    matchIdBuffer.append(match.match_id)
                    count+=1
                    
                    // Break loop once we've grabbed 10 matches
                    if (count >= 10) {
                        count = 0
                        break
                    }
                }
                // Fill an int, array dictionary where the key is an account ID and the value is an array of matches
                topPlayersRecentMatches.updateValue(matchIdBuffer, forKey: player.key)
                matchIdBuffer.removeAll()
            }
        }
        return topPlayersRecentMatches
    }
}
