//
//  OpenDotaService.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import Foundation
class OpenDotaService
{
    // Constants
    var OPEN_DOTA_URL = "https://api.opendota.com"
    
    // Error Enums
    // ***************************************************************************************************************************
    
    // Open Dota API call potential errors
    enum ApiError: Error {
        case invalidURL
        case invalidReponse
        case invalidData
        case noData
    }
    
    // ***************************************************************************************************************************

    // Open Dota API data objects // TODO: Add API keys
    // ***************************************************************************************************************************
    
    
    struct Account: Codable
    {
        let profile: Profile
        let rank_tier: Int?
    }
    
    struct Profile: Codable
    {
        let account_id: Int
    }
    
    struct Player: Codable
    {
        let account_id: Int?
        let hero_id: Int
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
    
    struct Hero: Codable
    {
        let id: Int?
        let name: String
        let localized_name: String
        let primary_attr: String?
        let attack_types: String?
        let roles: [String]?
        let legs: Int?
    }
    
    struct Item: Codable
    {
//      let abilities: [Ability] (could add later)
//      let hint: [String]
        let name: String
        let id: Int
        let img: String
        let dname: String?
        let qual: String?
        let cost: Int?
//      let behavior: String
//      let dmgType: String?
//      let notes: String?
//      let attrib: [Attribute] (could add later)
//      let mc: Bool?
//      let hc: Bool?
//      let cd: Int?
//      let lore: String?
//      let components: [String]?
//      let created: Bool?
//      let charges: Bool?
    }
    
    // ***************************************************************************************************************************
    
    // Open Dota API Calls
    // ***************************************************************************************************************************
    
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/players/\(accountID)")
        
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/search/?q=\(personaname)")
        
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/matches/\(matchId)")
        
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/players/\(accountId)/recentMatches")
        
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/publicMatches/?min_rank=81")
        
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
        let data = try await openDotaAPICall(endpoint: "\(OPEN_DOTA_URL)/api/heroes")
        
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
    // ***************************************************************************************************************************
    
    
    // Data calculations for received match and player data
    // ***************************************************************************************************************************
    
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
        
        // If no match data received throw error
        if (matchIDs.isEmpty) {
            print("Error in getPlayerMatchData()")
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
    
    // Get pro player match data from 20 recent pro matches
    func getProMatchData(matchIDs: [Int]) async throws -> [Player]
    {
        var matches: [Match] = []
        var proData: [Player] = []
        var count = 0
        
        // If no match data received throw error
        if (matchIDs.isEmpty) {
            print("Error in getProMatchData()")
            throw ApiError.noData
        }
        
        // get first 20 pro match objects
        for matchID in matchIDs {
            if (count < 20) {
                matches.append(try await fetchMatch(matchId: matchID))
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
    func getAverageGPM(data: [Player]) throws -> Int
    {
        var GPM = 0
        
        // If we didn't receive data get out
        if (data.isEmpty) {
            print("Error in getAverageGPM()")
            throw ApiError.noData
        }
        
        // Pull GPM from players recent match data
        for player in data {
            GPM += player.gold_per_min ?? 0
        }
        // Find avg by dividing by number of matches
        GPM = GPM/data.count
        
        return GPM
    }
    
    // Determine the heros played by the provided players
    // Return dict [hero id : games played]
    func getHeroes(data: [Player], heroes: [Hero]) throws -> Array<(key: Int, value: Int)>
    {
        // <Hero ID, Number of matches played>
        var heroesPlayed: Dictionary<Int, Int> = [:]
        
        // If we didn't receive data get out
        if (data.isEmpty) {
            print("Error in getHeroes()")
            throw ApiError.noData
        }
        
        for player in data {
            // If the played hero hasnt been added to the dictionary yet add it
            if !heroesPlayed.keys.contains(player.hero_id) {
                heroesPlayed.updateValue(0, forKey: player.hero_id)
            }
            // Increment the count for that hero
            heroesPlayed[player.hero_id]! += 1
        }
        
        // Sort from most played to least played
        return heroesPlayed.sorted(by: {$0.value > $1.value})
    }
    
    // Convert recently played hero IDs to string hero names
    func heroListToString(data: Dictionary<Int, Int>, allHeroes: [Hero]) -> Dictionary<String, Int>
    {
        // Used to keep track of hero string being added to dict
        var nextHeroIndex = 0
        
        // Dict to be returned with hero ids converted to strings
        var heroesPlayedStrings: Dictionary<String, Int> = [:]
        
        // For every recently played hero convert the hero id to its string hero name and add it to a new dict that can be used by the UI
        for entry in data {
            nextHeroIndex = allHeroes.firstIndex { hero in
                hero.id == entry.key
            }!
            heroesPlayedStrings.updateValue(entry.value, forKey: allHeroes[nextHeroIndex].localized_name)
            
        }
        
        return heroesPlayedStrings
    }
    
    // Take a given hero ID and returns its string hero name
    func heroIdToString(heroId: Int, allHeroes: [Hero]) -> String
    {
        for hero in allHeroes {
            if (hero.id == heroId) {
                return hero.name
            }
        }
        
        print("Issue in HeroIdToString()")
        print("No hero found for the provided ID: \(heroId)")
        return ""
    }
    
    // Take a given item ID and returns its string item name
    func itemIdToString(itemId: Int, allItems: [Item]) -> String
    {
        for item in allItems {
            if (item.id == itemId) {
                return item.name
            }
        }

        // Don't bother logging an issue for empty item slot 
        if (itemId != 0) {
            print("Issue in ItemIdToString()")
            print("No item found for the provided ID: \(itemId)")
        }
        
        return ""
    }
    
    // Get comparable pro builds based on heroes the selected player plays
    func getHeroBuilds(data: [Player], playerHeroes: Array<(key: Int, value: Int)>) throws -> [Player]
    {
        var topThree: Array<(key: Int, value: Int)> = []
        var heroBuilds: [Player] = []
        
        // If we didn't receive data get out
        if (data.isEmpty) {
            print("Error in getHeroBuilds()")
            throw ApiError.noData
        }
        
        // Identify selected player's top three most played heroes
        // This assumes that 'playerHeroes' comes sorted
        for i in 0...2 {
            topThree.append((key: playerHeroes[i].key, value: playerHeroes[i].value))
        }
        
        // Collect pro player builds for selected players most played heroes
        for pro in data {
            if (topThree.contains(where: ({$0.key == pro.hero_id}))) {
                heroBuilds.append(pro)
            }
        }
        
        return heroBuilds
    }
    
    // Produce the CDN URL for a given hero name (used to grab hero image for front end)
    func getHeroImageLink(heroName: String) -> String
    {
        // Extract substring of the hero name from the string ex: npc_dota_hero_death_prophet -> death_prophet
        if let range = heroName.range(of: "npc_dota_hero_") {
            let formattedHeroName = heroName[range.upperBound...]
            return ("https://cdn.dota2.com/apps/dota2/images/heroes/\(formattedHeroName.lowercased())_full.png")
        }
        
        print("Invalid hero name provided to fetch image")
        return ""
    }
    
    // Produce the CDN URL for a given item name (used to grab item image for front end)
    func getItemImageLink(itemName: String) -> String
    {
        return ("https://cdn.dota2.com/apps/dota2/images/items/\(itemName.lowercased())_lg.png")
    }
    // ***************************************************************************************************************************
    
}
