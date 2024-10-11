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
    @State var profilePic: String
    @State var proData: [OpenDotaService.Player] = []
    
    // Selected player and pro player data used for calculating why the selected player sucks
    @State var playerAccountInfo: OpenDotaService.Account?
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
    @State var itemData: [OpenDotaService.Item] = []
    
    
    var body: some View {
        VStack {
            // Selected player Steam profile pic (avatar)
            AsyncImage(url:URL(string: profilePic)) { avatar in avatar
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            // Selected player Steam account name
            Text(personaname)
            // Selected player Dota rank
            Text(String(playerAccountInfo?.rank_tier ?? 0))
            
            // List recently played heroes by selected player
            List(heroBuilds, id: \.net_worth) {
                build in
                    VStack {
                        AsyncImage(url:URL(string: ODS.getHeroImageLink(heroName: ODS.heroIdToString(heroId: build.hero_id, allHeroes: heroData)))) { heroImage in heroImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 44, height: 44)
                        Text("Kills: \(build.kills ?? 0)")
                        Text("Deaths: \(build.deaths ?? 0)")
                        Text("Assists: \(build.assists ?? 0)")
                        
                        HStack {
                            // Item 1 image
                            AsyncImage(url:URL(string: ODS.getItemImageLink(itemName: ODS.itemIdToString(itemId: build.item_0 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 2 image
                            AsyncImage(url:URL(string: ODS.getItemImageLink(itemName: ODS.itemIdToString(itemId: build.item_1 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 3 image
                            AsyncImage(url:URL(string: ODS.getItemImageLink(itemName: ODS.itemIdToString(itemId: build.item_2 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 4 image
                            AsyncImage(url:URL(string: ODS.getItemImageLink(itemName: ODS.itemIdToString(itemId: build.item_3 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 5 image
                            AsyncImage(url:URL(string: ODS.getItemImageLink(itemName: ODS.itemIdToString(itemId: build.item_4 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 6 image
                            AsyncImage(url:URL(string: ODS.getItemImageLink(itemName: ODS.itemIdToString(itemId: build.item_5 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
            }.navigationTitle("")
            
            Text("Your average GPM: \(String(playerGPM))")
            Text("Immortal player average GPM: \(String(proGPM))")
        }
        .task {
            do {
                // Fetch selected player information
                playerAccountInfo = try await ODS.fetchAccount(accountID: account_ID)
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
    PlayerDataView(account_ID: 0, personaname: "Tilted Warlord", profilePic: "", proData: [])
}
