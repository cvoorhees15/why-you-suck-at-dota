//
//  PlayerDataView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/10/24.
//

import SwiftUI

struct PlayerDataView: View {
    
    // API
    var ODS = OpenDotaService()
    var ODM = OpenDotaManager()
    
    // Params from SearchView
    @State var account_ID: Int
    @State var personaname: String
    @State var profilePic: String
    @State var proData: [Player] = []
    
    // Selected player and pro player data used for determining why the selected player sucks
    @State var playerAccountInfo: Account?
    @State var playerGPM = 0
    @State var proGPM = 0
    @State var playerHeroesPlayed: Array<(key: Int, value: Int)> = []
    @State var proHeroesPlayed: Array<(key: Int, value: Int)> = []
    @State var heroBuilds: [Player] = []
    
    // Data from API calls
    @State var playerMatches: [RecentMatch] = []
    @State var proMatches: [ProMatch] = []
    @State var playerData: [Player] = []
    @State var heroData: [Hero] = []
    @State var itemData: [Item] = []
    
    
    var body: some View {
        VStack {
            // Selected player Steam profile pic (avatar)
            AsyncImage(url:URL(string: profilePic)) { avatar in avatar
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            // Selected player Steam account name
            Text(personaname)
                .font(.title)
                .bold()
            // Selected player Dota rank
            Text("Rank: \(String(playerAccountInfo?.rank_tier ?? 0))")
            
            Text("Your average GPM: \(String(playerGPM))")
            Text("Immortal player average GPM: \(String(proGPM))")
            
            Text("This is how Immortals play your heroes:")
                .font(.title3)
            // List recently played heroes by selected player
            // TODO: net_worth isn't a true unique ID
            List(heroBuilds, id: \.net_worth) {
                build in
                    VStack {
                        AsyncImage(url:URL(string: ODM.getHeroImageLink(heroName: ODM.heroIdToString(heroId: build.hero_id, allHeroes: heroData)))) { heroImage in heroImage
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
                            AsyncImage(url:URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_0 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 2 image
                            AsyncImage(url:URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_1 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 3 image
                            AsyncImage(url:URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_2 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 4 image
                            AsyncImage(url:URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_3 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 5 image
                            AsyncImage(url:URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_4 ?? 0, allItems: itemData)))) { heroImage in heroImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            // Item 6 image
                            AsyncImage(url:URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_5 ?? 0, allItems: itemData)))) { heroImage in heroImage
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
        }
        .task {
            do {
                // Fetch selected player information
                playerAccountInfo = try await ODS.fetchAccount(accountID: account_ID)
                playerMatches = try await ODS.fetchRecentMatches(accountId: account_ID)
                
                // Pull a subset of data
                playerData = try await ODS.pullPlayerDataFromMatches(matchIDs: ODM.getRecentMatchIDs(recentMatches: playerMatches), accountID: account_ID)
                
                // Make calculations with player and pro data to create comparisons
                try playerGPM = ODM.getAverageGPM(data: playerData)
                try proGPM = ODM.getAverageGPM(data: proData)
                try playerHeroesPlayed = ODM.getHeroes(data: playerData, heroes: heroData)
                try proHeroesPlayed = ODM.getHeroes(data: proData, heroes: heroData)
                try heroBuilds = ODM.getHeroBuilds(data: proData, playerHeroes: playerHeroesPlayed)
            }
            catch ApiError.invalidURL {
                print ("invalid URL")
            }
            catch ApiError.invalidReponse {
                print ("invalid response")
            }
            catch ApiError.invalidData {
                print ("invalid data")
            }
            catch ApiError.noData {
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
