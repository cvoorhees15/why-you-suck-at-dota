//
//  PlayerDataView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/10/24.
//

import SwiftUI
import Charts

struct PlayerDataView: View {
    
    // API
    var ODS = OpenDotaService()
    var ODM = OpenDotaManager()
    
    // Variables used for view state
    @State var isViewLoading = false
    @State var playerHasData = true
    
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
    
    // Basic GroupBox style to make chart backgrounds transparent
    struct PlainGroupBoxStyle: GroupBoxStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading) {
                configuration.label
                    .font(.headline)
                    .foregroundColor(.white)
                configuration.content
                    .background(Color(.systemGray6).opacity(0.1))
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.main, Color.appSmudge]),
                startPoint: .leading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Ensure gradient fills the entire screen
            ScrollView
            {
                VStack {
                    // Selected player Steam account name
                    Text(personaname)
                        .font(.title)
                        .bold()
                    
                    // Selected player Steam profile pic (avatar)
                    AsyncImage(url:URL(string: profilePic)) { avatar in avatar
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .foregroundColor(.secondary)
                    }
                    
                    // Selected player Dota rank
                    Image(ODM.getRankImage(rankTier: playerAccountInfo?.rank_tier ?? 0))
                        .resizable()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
//                    FIXME: Pushing contents off screen
//                    Image(ODM.getRankStarImage(rankTier: playerAccountInfo?.rank_tier ?? 0))
//                        .resizable()
//                        .frame(width: 70, height: 70)
//                        .clipShape(Circle())
                }
                .toolbarBackground(.main)
                HStack {
                    GroupBox("Gold / Minute") {
                        Chart {
                            BarMark(x: .value("Player GPM", "You"),
                                    y: .value("GPM", playerGPM))
                            .foregroundStyle(.green)
                            BarMark(x: .value("Pro GPM", "Immortals"),
                                    y: .value("GPM", proGPM))
                            .foregroundStyle(.red)
                        }
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                        .chartYAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .groupBoxStyle(PlainGroupBoxStyle())
                    GroupBox("XP / Minute") {
                        Chart {
                            BarMark(x: .value("Player XPM", "You"),
                                    y: .value("XPM", playerXPM))
                            .foregroundStyle(.green)
                            BarMark(x: .value("Pro XPM", "Immortals"),
                                    y: .value("XPM", proXPM))
                            .foregroundStyle(.red)
                        }
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                        .chartYAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .groupBoxStyle(PlainGroupBoxStyle())
                }
                HStack {
                    GroupBox("Net Worth") {
                        Chart {
                            BarMark(x: .value("Player NW", "You"),
                                    y: .value("Net Worth", playerNW))
                            .foregroundStyle(.green)
                            BarMark(x: .value("Pro Player NW", "Immortals"),
                                    y: .value("Net Worth", proNW))
                            .foregroundStyle(.red)
                        }
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                        .chartYAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .groupBoxStyle(PlainGroupBoxStyle())
                    GroupBox("Last Hits") {
                        Chart {
                            BarMark(x: .value("Player LH", "You"),
                                    y: .value("Last Hits", playerLH))
                            .foregroundStyle(.green)
                            BarMark(x: .value("Pro Player LH", "Immortals"),
                                    y: .value("Last Hits", proLH))
                            .foregroundStyle(.red)
                        }
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                        .chartYAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisTick()
                                    .foregroundStyle(.white)
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                                AxisGridLine()
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .groupBoxStyle(PlainGroupBoxStyle())
                }
                    Text("Immortal Builds For Your Heroes")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                if (heroBuilds.isEmpty) {
                    Text("No recent builds found for your heroes")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                else {
                    // List recently played heroes by selected player
                    // TODO: net_worth isn't a true unique ID
                    ForEach(heroBuilds, id: \.net_worth) {
                        build in
                        VStack(alignment: .center, spacing: 10) {
                            // Hero Image
                            AsyncImage(url: URL(string: ODM.getHeroIconLink(heroName: ODM.heroIdToString(heroId: build.hero_id, allHeroes: heroData)))) { heroImage in
                                heroImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Rectangle())
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            
                            // Stats
                            HStack {
                                Text("K: \(build.kills ?? 0)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("D: \(build.deaths ?? 0)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("A: \(build.assists ?? 0)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            // Items (Horizontally aligned)
                            HStack(alignment: .center, spacing: 8) {
                                // Item 1 image
                                AsyncImage(url: URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_0 ?? 0, allItems: itemData)))) { itemImage in
                                    itemImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 44, height: 44)
                                
                                // Item 2 image
                                AsyncImage(url: URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_1 ?? 0, allItems: itemData)))) { itemImage in
                                    itemImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 44, height: 44)
                                
                                // Item 3 image
                                AsyncImage(url: URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_2 ?? 0, allItems: itemData)))) { itemImage in
                                    itemImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 44, height: 44)
                                
                                // Item 4 image
                                AsyncImage(url: URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_3 ?? 0, allItems: itemData)))) { itemImage in
                                    itemImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 44, height: 44)
                                
                                // Item 5 image
                                AsyncImage(url: URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_4 ?? 0, allItems: itemData)))) { itemImage in
                                    itemImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 44, height: 44)
                                
                                // Item 6 image
                                AsyncImage(url: URL(string: ODM.getItemImageLink(itemName: ODM.itemIdToString(itemId: build.item_5 ?? 0, allItems: itemData)))) { itemImage in
                                    itemImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 44, height: 44)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.1))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                Text("Why \(personaname) Sucks At Dota")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                if (playerXPM < proXPM) {
                    Text("Get more involved during matches! XPM is low compared to immortal players who play your heroes...")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                if (playerNW < proNW) {
                    Text("Stop feeding! Overall net worth is low when compared to immortal players who play your heroes...")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                if (playerLH < proLH) {
                    Text("Hit more creeps! Last hit count is low when compared to immortal players who play your heroes...")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                if (playerGPM < proGPM) {
                    Text("Kill more heroes and creeps! GPM is low when compared to immortal players who play your heroes...")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                if (playerGPM > proGPM && playerLH > proLH && playerNW > proNW && playerXPM > proXPM) {
                    Text("\(personaname) might not suck at Dota... all their basic metrics are higher than immortal players who play their heroes. Keep it up!")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .opacity(isViewLoading || !playerHasData ? 0 : 1)
            
            VStack {
                Text("Loading Player Data...")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                ProgressView()
                    .padding()
                    .frame(width:100, height: 100)
                    .scaleEffect(3)
            }
            .opacity(isViewLoading ? 1 : 0)
            
            VStack {
                Text("no match data found for the selected player")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .opacity(!playerHasData ? 1 : 0)
        }
        .task {
            do {
                // Reset variables used for loading screen
                isViewLoading = true
                
                // Fetch selected player information
                playerAccountInfo = try await ODS.fetchAccount(accountID: account_ID)
                playerMatches = try await ODS.fetchRecentMatches(accountId: account_ID)
                
                // Identify the selected steam account has dota match data
                playerHasData = true
                
                // Pull a subset of selected player's matches
                playerData = try await ODS.pullPlayerDataFromMatches(matchIDs: ODM.getRecentMatchIDs(recentMatches: playerMatches), accountID: account_ID)
                
                // Get various metrics for selected player and pro players who play the same heroes
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
                
                // Turns off loading screen
                isViewLoading = false
                
            }
            catch ApiError.invalidURL {
                print ("invalid URL")
            }
            catch ApiError.invalidReponse {
                print ("invalid response")
                playerHasData = false
                isViewLoading = false
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
