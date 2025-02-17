//
//  AnimatedBackground.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 21/04/2024.
//

import Foundation
import SwiftUI

struct AnimatedBackground: View {
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 4, y: 0)
    @State var currentIndex = 0
    
    let timer = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
    let colors = [
        Color(hex: "#3756A6"),
        Color(hex: "#3756A6").opacity(0.3),
        Color(hex: "#3756A6").opacity(0.6),
        Color(hex: "#3756A6").opacity(0.9),
        Color.white
    ]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .onReceive(timer) { _ in
                withAnimation(Animation.easeInOut(duration: 6)) {
                    currentIndex = (currentIndex + 1) % colors.count
                    start = UnitPoint(x: Double.random(in: -4...4), y: Double.random(in: -4...4))
                    end = UnitPoint(x: Double.random(in: -4...4), y: Double.random(in: -4...4))
                }
            }
    }
}
