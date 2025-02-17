//
//  ProfileView.swift
//  2lab
//
//  Created by Phạm Việt Tú on 22/06/2024.
//

import Foundation
import SwiftUI
import ScrollViewSectionKit

struct ProfileView: View {
    @EnvironmentObject var viewModel: SettingViewModel
    
    var body: some View {
        LazyVStack {
            ScrollViewSection {
                if let email = viewModel.email {
                    HStack {
                        Text(LocalizedStringKey("email"))
                        Spacer()
                        Text(email)
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                }
                
                if let phone = viewModel.phone {
                    if let countryCode = viewModel.countryCode {
                        HStack {
                            Text(LocalizedStringKey("phone_number"))
                            Spacer()
                            Text("(\(countryCode))" + phone)
                                .font(.subheadline)
                                .opacity(0.5)
                        }
                    }
                }
                
                if let gender = viewModel.gender {
                    HStack {
                        Text(LocalizedStringKey("gender"))
                        Spacer()
                        Text(LocalizedStringKey(gender))
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                }
                
                if let dob = viewModel.dob {
                    HStack {
                        Text(LocalizedStringKey("dob"))
                        Spacer()
                        Text(LocalizedStringKey(dob.asStringDate(dateFormat: "dd-MM-yyyy")))
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                }
            } header: {
                Text(LocalizedStringKey("infomation"))
            }
            .scrollViewRowBackgroundColor(Color(UIColor.secondarySystemBackground))
            .scrollViewSectionBackgroundColor(.clear)
        }
    }
}
