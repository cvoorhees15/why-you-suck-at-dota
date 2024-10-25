//
//  OpenDotaManager.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 10/11/24.
//

import Foundation
class OpenDotaManager {
    
    // ****************************************************************************
    // Getter functions used to derive meaningful data points from larger data sets
    // ****************************************************************************
    
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
    
    // Get average XPM from multiple matches worth of player data
    func getAverageXPM(data: [Player]) throws -> Int
    {
        var XPM = 0
        
        // If we didn't receive data get out
        if (data.isEmpty) {
            print("Error in getAverageXPM()")
            throw ApiError.noData
        }
        
        // Pull XPM from players recent match data
        for player in data {
            XPM += player.xp_per_min ?? 0
        }
        // Find avg by dividing by number of matches
        XPM = XPM/data.count
        
        return XPM
    }
    
    // Get average net worth from multiple matches worth of player data
    func getAverageNetWorth(data: [Player]) throws -> Int
    {
        var NW = 0
        
        // If we didn't receive data get out
        if (data.isEmpty) {
            print("Error in getAverageNetWorth()")
            throw ApiError.noData
        }
        
        // Pull XPM from players recent match data
        for player in data {
            NW += player.net_worth ?? 0
        }
        // Find avg by dividing by number of matches
        NW = NW/data.count
        
        return NW
    }
    
    // Get average last hit count from multiple matches worth of player data
    func getAverageLastHits(data: [Player]) throws -> Int
    {
        var LH = 0
        
        // If we didn't receive data get out
        if (data.isEmpty) {
            print("Error in getAverageLastHits()")
            throw ApiError.noData
        }
        
        // Pull XPM from players recent match data
        for player in data {
            LH += player.last_hits ?? 0
        }
        // Find avg by dividing by number of matches
        LH = LH/data.count
        
        return LH
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
        // FIXME: This also assumes the player has at least 3 different heroes played in their latest 20 matches
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
    
    // ***************************************************************************
    // Getter functions to get Dota related images from a content delivery network
    // ***************************************************************************
    
    // Produce the CDN URL for a given hero name (used to grab hero icon for front end)
    func getHeroIconLink(heroName: String) -> String
    {
        // Extract substring of the hero name from the string ex: npc_dota_hero_death_prophet -> death_prophet
        if let range = heroName.range(of: "npc_dota_hero_") {
            let formattedHeroName = heroName[range.upperBound...]
            return ("\(DOTA_CDN_URL)/heroes/\(formattedHeroName.lowercased())_icon.png")
        }
        
        print("Invalid hero name provided to fetch image")
        return ""
    }
    
    // Produce the CDN URL for a given hero name (used to grab hero image for front end)
    func getHeroImageLink(heroName: String) -> String
    {
        // Extract substring of the hero name from the string ex: npc_dota_hero_death_prophet -> death_prophet
        if let range = heroName.range(of: "npc_dota_hero_") {
            let formattedHeroName = heroName[range.upperBound...]
            return ("\(DOTA_CDN_URL)/heroes/\(formattedHeroName.lowercased())_full.png")
        }
        
        print("Invalid hero name provided to fetch hero icon")
        return ""
    }
    
    // Produce the CDN URL for a given item name (used to grab item image for front end)
    func getItemImageLink(itemName: String) -> String
    {
        return ("\(DOTA_CDN_URL)/items/\(itemName.lowercased())_lg.png")
    }
    
    // Produce icon name for a given rank (used to grab rank icon from project assets)
    func getRankImage(rankTier: Int) -> String
    {
        if (rankTier != 0) {
            let rankTierString = String(rankTier)
            return ("rank_icon_\(rankTierString.first!)")
        }
        else {
            print("Invalid rank tier provided to fetch rank icon")
            return ""
        }
    }
    
    // Produce image name for a given rank
    func getRankStarImage(rankTier: Int) -> String
    {
        if (rankTier != 0) {
            let rankTierString = String(rankTier)
            return ("rank_star_\(rankTierString.last!)")
        }
        else {
            print("Invalid rank tier provided to fetch stars")
            return ""
        }
    }
    
    // ***************************************************
    // To string functions to translate various id numbers
    // ***************************************************
    
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
    
    // Convert recently played hero IDs to string hero names (within a dict)
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
            heroesPlayedStrings.updateValue(entry.value, forKey: allHeroes[nextHeroIndex].name)
            
        }
        
        return heroesPlayedStrings
    }
    
    // *********************************
    // Create structures using API data
    // *********************************
    
    // Create array from individual dota items
    func createItemsArray(item1: Int, item2: Int, item3: Int, item4: Int, item5: Int, item6: Int) -> [Int]
    {
        var itemsArray: [Int] = []
        
        itemsArray.append(item1)
        itemsArray.append(item2)
        itemsArray.append(item3)
        itemsArray.append(item4)
        itemsArray.append(item5)
        itemsArray.append(item6)
        
        return itemsArray
    }
}
