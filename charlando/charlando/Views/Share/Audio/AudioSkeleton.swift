//
//  AudioSkeleton.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/03/2024.
//

import Foundation
import SwiftUI

struct AudioSkeleton: View {
    var body: some View {
        HStack() {
            Image(systemName: "play.fill")
                .font(.system(size: 25))
                .foregroundColor(.red)
            Spacer()
            Rectangle()
                .frame(height: 5)
                .foregroundColor(.white)
                .cornerRadius(5)
        }
        .padding(.horizontal, 10)
        .frame(height: 40)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
