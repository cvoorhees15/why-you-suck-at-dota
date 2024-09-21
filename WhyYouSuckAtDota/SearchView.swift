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
                    
                    NavigationLink(searchResult.personaname, destination: PlayerDataView(account_ID: searchResult.account_id, personaname: searchResult.personaname, proData: proData, heroData: heroData))
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
        // API call for pro player match data and dota hero/item data
        .task {
            do {
                // TODO: Get pro player data and dota hero data once at the beginning of the session (not every time this view loads)
                proMatches = try await ODS.fetchProPubMatches()
                proData = try await ODS.getProMatchData(matchIDs: ODS.getProMatchIDs(proMatches: proMatches))
                heroData = try await ODS.fetchDotaHeros()
                // TODO: Fetch item data
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
