//
//  DataView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/10/24.
//

import SwiftUI

struct PlayerDataView: View {
    
    var ODS = OpenDotaService()
    
    // Params from SearchView
    @State var account_ID: Int
    @State var personaname: String
    @State var proData: [OpenDotaService.Player] = []
    
    // Selected player and pro player data used for calculating why the selected player sucks
    @State var playerGPM = 0
    @State var proGPM = 0
    @State var heroesPlayed: Array<(key: String, value: Int)> = []
    
    // Data from API calls
    @State var playerMatches: [OpenDotaService.RecentMatch] = []
    @State var proMatches: [OpenDotaService.ProMatch] = []
    @State var playerData: [OpenDotaService.Player] = []
    @State var heroData: [OpenDotaService.Hero] = []
    
    
    var body: some View {
        VStack {
            // List recently played heroes
            List(heroesPlayed, id: \.key) {
                hero in
                if (hero.key != "Unknown") {
                    HStack {
                        Text("\(hero.key): \(hero.value)")
                    }
                }
            }.navigationTitle("Recent Heroes")
            
            Text("Your average GPM: \(String(playerGPM))")
            Text("Immortal player average GPM: \(String(proGPM))")
        }
        .task {
            do {
                // Get all recent match data for the selected player
                playerMatches = try await ODS.fetchRecentMatches(accountId: account_ID)
                playerData = try await ODS.getPlayerMatchData(matchIDs: ODS.getRecentMatchIDs(recentMatches: playerMatches), accountID: account_ID)
                
                // Make calculations with player and pro data to create comparisons
                try playerGPM = ODS.getAverageGPM(data: playerData)
                try proGPM = ODS.getAverageGPM(data: proData)
                try heroesPlayed = ODS.getPlayerHeroes(data: playerData, heroes: heroData)
            }
            catch OpenDotaService.ApiError.invalidURL {
                print ("invalid URL")
            }
            catch OpenDotaService.ApiError.invalidReponse {
                print ("invalid response")
            }
            catch OpenDotaService.ApiError.invalidData {
                print ("invalid data")
            }
            catch OpenDotaService.DataError.noData {
                print ("No match data for the selected player")
            }
            catch {
                print ("unexpected error")
            }
        }
    }
}

#Preview {
    PlayerDataView(account_ID: 0, personaname: "Tilted Warlord", proData: [])
}
