//
//  SearchView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import SwiftUI

struct SearchView: View {
    
    var ODS = OpenDotaService()
    var ODM = OpenDotaManager()
    
    // Stores user search bar input
    @State private var searchTerm = ""
    
    // Data from API calls
    @State private var profile: Profile?
    @State private var searchResults: [SearchResult] = []
    @State var proData: [Player] = []
    @State var proMatches: [ProMatch] = []
    @State var heroData: [Hero] = []
    @State var itemData: [Item] = []

    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.main, Color.appRed]),
                    startPoint: .leading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea() // Ensure gradient fills the entire screen
                
                // List of persona name search results
                List(searchResults, id: \.account_id) { searchResult in
                    HStack(spacing: 20) {
                        AsyncImage(url: URL(string: searchResult.avatarfull)) { avatar in
                            avatar
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 44, height: 44)
                        
                        // NavigationLink for player details
                        NavigationLink(
                            searchResult.personaname,
                            destination: PlayerDataView(
                                account_ID: searchResult.account_id,
                                personaname: searchResult.personaname,
                                profilePic: searchResult.avatarfull,
                                proData: proData,
                                heroData: heroData,
                                itemData: itemData
                            )
                        )
                        .font(.title3)
                        .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .background(Color(.main))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
                    .listRowBackground(Color.clear) // Clear background for list rows
                    .listRowSeparator(.hidden) // Hide row separators
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // Removes the default List background
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Player Search")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemGray))
                }
            }
            .searchable(text: $searchTerm, prompt: "Enter Account Name")
            .onSubmit(of: .search) {
                Task {
                    do {
                        searchResults = try await ODS.fetchSearchResults(personaname: searchTerm)
                    } catch ApiError.invalidURL {
                        print("invalid URL")
                    } catch ApiError.invalidReponse {
                        print("invalid response")
                    } catch ApiError.invalidData {
                        print("invalid data")
                    } catch {
                        print("unexpected error")
                    }
                }
            }
        }
        .foregroundColor(.white)
        // API calls for pro player match data and dota hero/item data (on start of the app)
        .task {
            do {
                // TODO: Get this data ONCE at the beginning of the session (these are all getting called THREE times on startup)
                itemData = try ODS.fetchDotaItems()
                proMatches = try await ODS.fetchProPubMatches()
                heroData = try await ODS.fetchDotaHeroes()
                
                // Pull a subset of data
                proData = try await ODS.pullProDataFromMatches(matchIDs: ODM.getProMatchIDs(proMatches: proMatches))
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
            catch {
                print ("unexpected error")
            }
        }
    }
}

#Preview {
    SearchView()
}
