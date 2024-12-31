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
    
    // Search term variables
    @State private var searchName = ""
    @State private var searchId = ""
    
    // UI state keeper
    @State private var viewState: SearchViewState = SearchViewState.idle
    
    // Data from API calls
    @State private var profile: Profile?
    @State private var nameSearchResults: [SearchResult] = []
    @State private var accountSearchResult: Account?
    @State var proData: [Player] = []
    @State var proMatches: [ProMatch] = []
    @State var heroData: [Hero] = []
    @State var itemData: [Item] = []

    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.main, Color.appSmudge]),
                    startPoint: .leading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea() // Ensure gradient fills the entire screen
                
                // Display error message if search results cannot load
                if (viewState == SearchViewState.idSearchError || viewState == SearchViewState.nameSearchError) {
                    VStack {
                        Text("error searching for player")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .bold()
                            .padding()
                        Text("ensure device is connected to the internet")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .bold()
                    }
                }
                VStack {
                    // Text input field for searching by ID
                    // Shows a navigation link if a valid player is found
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray.opacity(0.15))
                        TextField("", text: $searchId, prompt: Text("Search By Steam Friend ID").foregroundColor(.gray.opacity(0.15)))
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocorrectionDisabled(true)
                            .disableAutocorrection(true)
                            // Attempt to fetch the account on submission of an ID
                            .onSubmit {
                                if !searchId.isEmpty {
                                    viewState = SearchViewState.idSearchSuccessful
                                    Task {
                                        do {
                                            accountSearchResult = try await ODS.fetchAccount(accountID: Int(searchId) ?? 0)
                                            viewState = SearchViewState.idSearchSuccessful
                                        } catch ApiError.invalidURL {
                                            print("invalid URL")
                                            viewState = SearchViewState.idSearchError
                                        } catch ApiError.invalidReponse {
                                            print("invalid response")
                                            viewState = SearchViewState.idSearchError
                                        } catch ApiError.invalidData {
                                            print("invalid data")
                                            viewState = SearchViewState.idSearchError
                                        } catch {
                                            print("unexpected error")
                                            viewState = SearchViewState.idSearchError
                                        }
                                    }
                                }
                            }
                    }
                .padding(7)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.gray).opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.gray), lineWidth: 0)
                )
                .padding(.horizontal)
                    // If the user ID search was succsessful, show nav link to go view the players stats
                    if (viewState == SearchViewState.idSearchSuccessful) {
                        VStack {
                            if (accountSearchResult?.profile.personaname != "") {
                                Text("tap username to continue")
                                    .font(.title)
                                    .padding()
                            }
                            // Pass data to PlayerDataView:
                            // ---------------------------
                            // SELECTED PLAYER DATA: acc id, name, pro pic
                            // CONSTANT DATA: heroes, pro player matches, items
                            NavigationLink(
                                accountSearchResult?.profile.personaname ?? "",
                                destination: PlayerDataView(
                                    account_ID: Int(searchId) ?? 0,
                                    personaname: accountSearchResult?.profile.personaname ?? "",
                                    profilePic: accountSearchResult?.profile.avatarfull ?? "",
                                    proData: proData,
                                    heroData: heroData,
                                    itemData: itemData
                                )
                            )
                            .font(.title3)
                            .italic()
                            .padding()
                            .foregroundColor(.blue)
                        }
                    }
                
                // Search input field to list steam accounts based on search term
                List(nameSearchResults, id: \.account_id) { searchResult in
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
                        
                        // Pass data to PlayerDataView:
                        // ---------------------------
                        // SELECTED PLAYER DATA: acc id, name, pro pic
                        // CONSTANT DATA: heroes, pro player matches, items
                        NavigationLink(
                            searchResult.personaname,
                            destination: PlayerDataView(
                                account_ID: searchResult.account_id,
                                personaname: searchResult.personaname,
                                profilePic: searchResult.avatarfull,
                                heroData: heroData,
                                itemData: itemData
                            )
                        )
                        .font(.title3)
                        .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .background(Color(.main))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.gray), lineWidth: 1)
                    )
                    .listRowBackground(Color.clear) // Clear background for list rows
                    .listRowSeparator(.hidden) // Hide row separators
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // Removes the default List background
                .opacity(viewState != SearchViewState.nameSearchSuccessful ? 0 : 1)
            }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Player Search")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.white))
                }
            }
            .toolbarBackground(.main)
            .searchable(text: $searchName, prompt: "Search By Account Name")
            // Attempt to fetch the search results on submission of a search term
            .onSubmit(of: .search) {
                Task {
                    do {
                        nameSearchResults = try await ODS.fetchSearchResults(personaname: searchName)
                        viewState = SearchViewState.nameSearchSuccessful
                    } catch ApiError.invalidURL {
                        print("invalid URL")
                        viewState = SearchViewState.nameSearchError
                    } catch ApiError.invalidReponse {
                        print("invalid response")
                        viewState = SearchViewState.nameSearchError
                    } catch ApiError.invalidData {
                        print("invalid data")
                        viewState = SearchViewState.nameSearchError
                    } catch {
                        print("unexpected error")
                        viewState = SearchViewState.nameSearchError
                    }
                }
            }
        }
        .foregroundColor(.white)
        // API calls for pro player match data and dota hero/item data (on start of the app)
        .task {
            do {
                itemData = try ODS.fetchDotaItems()
                proMatches = try await ODS.fetchProPubMatches()
                heroData = try await ODS.fetchDotaHeroes()
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
