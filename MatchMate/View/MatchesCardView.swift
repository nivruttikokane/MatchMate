//
//  MatchesCardView.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct MatchesCardView: View {
    @Binding var data: ProfileMatchesModel
    
    var status: MatchStatus {
        return MatchStatus(rawValue: data.status) ?? .pending
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            WebImage(url: URL(string: data.imageUrl)) { image in
                    image
                .resizable()
                .scaledToFill()
                } placeholder: {
                    Rectangle().foregroundColor(.gray)
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(width: screenWidth/2.5, height: screenWidth/2.5, alignment: .center)
                .padding(.top, 10)
            
            Text(data.name)
                .foregroundStyle(Color(red: 17/255, green: 177/255, blue: 201/255))
                .fontWeight(.bold)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 0)
            
            Text(data.address)
                .foregroundStyle(.gray)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 0)
                .lineLimit(2)
            
            
            switch status {
            case .accepted:
                Text("Accepted")
                    .foregroundStyle(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 17/255, green: 177/255, blue: 201/255))
                    )
            case .pending:
                HStack(spacing: 50) {
                    declineButton

                    acceptButton
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            case .rejected:
                Text("Rejected")
                    .foregroundStyle(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 17/255, green: 177/255, blue: 201/255))
                    )
            }
    
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.5), radius: 10)
        }
        .frame(height: 400)
    }
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    var acceptButton: some View {
        Button {
            data.status = MatchStatus.accepted.rawValue
            let object = CoreDataManager.shared.checkExistence(objectType: UserMatches.self, id: data.id, key: "id").1
            for data in object {
                data.status = MatchStatus.accepted.rawValue
                CoreDataManager.shared.saveContext()
            }
            
        } label: {
            Circle()
                .stroke(Color(red: 17/255, green: 177/255, blue: 201/255), lineWidth: 2)
                .frame(width: 50, height: 50)
                .overlay {
                    Text("\u{2713}")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(.gray)
                }
        }
    }
    
    var declineButton: some View {
        Button {
            data.status = MatchStatus.rejected.rawValue
            let object = CoreDataManager.shared.checkExistence(objectType: UserMatches.self, id: data.id, key: "id").1
            for data in object {
                data.status = MatchStatus.rejected.rawValue
                CoreDataManager.shared.saveContext()
            }
        } label: {
            Circle()
                .stroke(Color(red: 17/255, green: 177/255, blue: 201/255), lineWidth: 2)
                .frame(width: 50, height: 50)
                .overlay {
                    Text("X")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(.gray)
                }
        }
    }
}

#Preview {
    MatchesCardView(
        data: .constant(ProfileMatchesModel(
            id: "",
            imageUrl: "",
            name: "",
            address: "",
            status: MatchStatus.accepted.rawValue
        ))
    )
}
