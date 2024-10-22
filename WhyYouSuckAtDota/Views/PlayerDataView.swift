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
    
    // Variables used for loading screen
    @State var isViewLoading = true
    @State var loadingProgress = 0.0
    
    // Params from SearchView
    @State var account_ID: Int
    @State var personaname: String
    @State var profilePic: String
    @State var proData: [Player] = []
    
    // Selected player and pro player data used for determining why the selected player sucks
    @State var playerAccountInfo: Account?
    @State var playerGPM = 0
    @State var playerXPM = 0
    @State var playerNW = 0
    @State var playerLH = 0
    @State var proGPM = 0
    @State var proXPM = 0
    @State var proNW = 0
    @State var proLH = 0
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
        ZStack {
            VStack {
                // Selected player Steam account name
                Text(personaname)
                    .font(.title)
                    .bold()
                
                // Selected player Steam profile pic (avatar)
                AsyncImage(url:URL(string: profilePic)) { avatar in avatar
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
                
                // Selected player Dota rank
                Image(ODM.getRankImage(rankTier: playerAccountInfo?.rank_tier ?? 0))
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)
                Image(ODM.getRankStarImage(rankTier: playerAccountInfo?.rank_tier ?? 0))
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 60, height: 60)
                
                // Selected Player Average Stats
                Text("Player Averages")
                    .font(.title2)
                    .bold()
                    .frame(alignment: .center)
                HStack {
                    VStack {
                        Text("GPM")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(playerGPM))
                    }
                    .padding()
                    VStack {
                        Text("XPM")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(playerXPM))
                    }
                    .padding()
                    VStack {
                        Text("Net")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(playerNW))
                    }
                    .padding()
                    VStack {
                        Text("CS")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(playerLH))
                    }
                    .padding()
                }
                
                // Pro Player Average Stats
                Text("Immortal Averages")
                    .font(.title2)
                    .bold()
                    .frame(alignment: .center)
                HStack {
                    VStack {
                        Text("GPM")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(proGPM))
                    }
                    .padding()
                    VStack {
                        Text("XPM")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(proXPM))
                    }
                    .padding()
                    VStack {
                        Text("Net")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(proNW))
                    }
                    .padding()
                    VStack {
                        Text("CS")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .center)
                        Text(String(proLH))
                    }
                    .padding()
                }
                Text("Immortal Builds for Your Heroes")
                    .font(.title3)
                    .padding()
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
                }
            }.opacity(isViewLoading ? 0 : 1)
            
            VStack {
                Text("Loading Player Data...")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                ProgressView(value: loadingProgress)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .opacity(isViewLoading ? 1 : 0)
        }
        .task {
            do {
                // Reset variables used for loading screen
                isViewLoading = true
                loadingProgress = 0.0
                
                // Fetch selected player information
                playerAccountInfo = try await ODS.fetchAccount(accountID: account_ID)
                
                playerMatches = try await ODS.fetchRecentMatches(accountId: account_ID)
                
                loadingProgress = 0.5
                
                // Pull a subset of player data
                playerData = try await ODS.pullPlayerDataFromMatches(matchIDs: ODM.getRecentMatchIDs(recentMatches: playerMatches), accountID: account_ID)
                
                loadingProgress = 1.0
                
                // Make calculations with player and pro data to create comparisons
                // Selected Player
                try playerGPM = ODM.getAverageGPM(data: playerData)
                
                try playerXPM = ODM.getAverageXPM(data: playerData)
                
                try playerNW = ODM.getAverageNetWorth(data: playerData)
                
                try playerLH = ODM.getAverageLastHits(data: playerData)
                
                try playerHeroesPlayed = ODM.getHeroes(data: playerData, heroes: heroData)
                
                // Pro player
                try proHeroesPlayed = ODM.getHeroes(data: proData, heroes: heroData)
                try heroBuilds = ODM.getHeroBuilds(data: proData, playerHeroes: playerHeroesPlayed)
                try proGPM = ODM.getAverageGPM(data: heroBuilds)
                try proXPM = ODM.getAverageGPM(data: heroBuilds)
                try proNW = ODM.getAverageNetWorth(data: heroBuilds)
                try proLH = ODM.getAverageLastHits(data: heroBuilds)
                
                
                isViewLoading = false
                
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
