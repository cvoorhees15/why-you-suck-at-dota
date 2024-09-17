//
//  DataView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/10/24.
//

import SwiftUI

struct PlayerDataView: View {
    
    @State var account_ID: Int
    @State var personaname: String
    @State var playerGPM = 0
    @State var proGPM = 0
    @State var playerMatches: [OpenDotaService.RecentMatch] = []
    @State var proMatches: [OpenDotaService.ProMatch] = []
    @State var playerData: [OpenDotaService.Player] = []
    @State var proData: [OpenDotaService.Player] = []
    var ODS = OpenDotaService()
    var matchIDs: [Int] = []
    
    
    
    var body: some View {
        VStack {
            Text("Your average GPM: \(String(playerGPM))")
            Text("Pro player GPM: \(String(proGPM))")
        }
        .task {
            do {
                playerMatches = try await ODS.fetchRecentMatches(accountId: account_ID)
                proMatches = try await ODS.fetchProPubMatches()
                playerData = try await ODS.getPlayerMatchData(matchIDs: ODS.getRecentMatchIDs(recentMatches: playerMatches), accountID: account_ID)
                proData = try await ODS.getProMatchData(matchIDs: ODS.getProMatchIDs(proMatches: proMatches), accountID: account_ID)
                playerGPM = ODS.getAverageGPM(Data: playerData)
                proGPM = ODS.getAverageGPM(Data: proData)
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

#Preview {
    PlayerDataView(account_ID: 0, personaname: "Tilted Warlord")
}
