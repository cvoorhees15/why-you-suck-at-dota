//
//  ContentView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import SwiftUI

struct SearchView: View {
    
    let ODS = OpenDotaService()
    
    // Stores user search bar input
    @State private var searchTerm = ""
    
    // Data from API calls
    @State private var profile: OpenDotaService.Profile?
    @State private var searchResults: [OpenDotaService.SearchResult] = []
    @State var proData: [OpenDotaService.Player] = []
    @State var proMatches: [OpenDotaService.ProMatch] = []
    @State var heroData: [OpenDotaService.Hero] = []
    @State var itemData: [OpenDotaService.Item] = []

    
    
    var body: some View {
        NavigationStack {
            // List of persona name search results
            List(searchResults, id: \.account_id) {
                searchResult in
                HStack(spacing: 20) {
                    AsyncImage(url:URL(string: searchResult.avatarfull)) { avatar in avatar
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 44, height: 44)
                    
                    // Pass data to PlayerDataView
                    // ---------------------------
                    // SELECTED PLAYER DATA: acc id, name, pro pic
                    // CONSTANT DATA: heroes, pro player matches, items
                    NavigationLink(searchResult.personaname, destination: PlayerDataView(account_ID: searchResult.account_id, personaname: searchResult.personaname, profilePic: searchResult.avatarfull, proData: proData, heroData: heroData, itemData: itemData))
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Steam Accounts")
            .searchable(text: $searchTerm, prompt: "Enter Account Name")
            // API call for list of steam accounts based on search criteria (on submission of search)
            .onSubmit(of: .search) {
                Task {
                    do {
                        // Get list of steam accounts by persona name search term
                        searchResults = try await ODS.fetchSearchResults(personaname: searchTerm)
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
                    catch {
                        print ("unexpected error")
                    }
                }
            }
        }
        // API calls for pro player match data and dota hero/item data (on start of the app)
        .task {
            do {
                // TODO: Get this data ONCE at the beginning of the session (these are all getting called THREE times on startup)
                itemData = try ODS.fetchDotaItems()
                proMatches = try await ODS.fetchProPubMatches()
                proData = try await ODS.getProMatchData(matchIDs: ODS.getProMatchIDs(proMatches: proMatches))
                heroData = try await ODS.fetchDotaHeroes()
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
            catch {
                print ("unexpected error")
            }
        }
        .padding()
    }
}

#Preview {
    SearchView()
}
