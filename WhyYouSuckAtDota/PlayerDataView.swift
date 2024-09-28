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
    @State var playerHeroesPlayed: Array<(key: Int, value: Int)> = []
    @State var proHeroesPlayed: Array<(key: Int, value: Int)> = []
    @State var heroBuilds: [OpenDotaService.Player] = []
    
    // Data from API calls
    @State var playerMatches: [OpenDotaService.RecentMatch] = []
    @State var proMatches: [OpenDotaService.ProMatch] = []
    @State var playerData: [OpenDotaService.Player] = []
    @State var heroData: [OpenDotaService.Hero] = []
    
    
    var body: some View {
        VStack {
            // List recently played heroes by selected player
            List(heroBuilds, id: \.net_worth) {
                build in
                    VStack {
                        Image("\(build.hero_id)")
                            .aspectRatio(contentMode: .fit)
                            .scaledToFit()
                            .clipShape(Circle())
                        Text("Kills: \(build.kills ?? 0)")
                        Text("Deaths: \(build.deaths ?? 0)")
                        Text("Assists: \(build.assists ?? 0)")
                    }
            }.navigationTitle("")
            
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
                try playerHeroesPlayed = ODS.getHeroes(data: playerData, heroes: heroData)
                try proHeroesPlayed = ODS.getHeroes(data: proData, heroes: heroData)
                try heroBuilds = ODS.getHeroBuilds(data: proData, playerHeroes: playerHeroesPlayed)
                
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
            catch OpenDotaService.ApiError.noData {
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
