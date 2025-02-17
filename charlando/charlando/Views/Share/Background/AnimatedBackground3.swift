//
//  AnimatedBackground3.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 21/04/2024.
//

import Foundation
import SwiftUI

struct AnimatedBackground3<Content: View>: View {
    let universalSize = UIScreen.main.bounds
    @State var isAnimated: Bool = false
    var useAnimation: Bool = true
    var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            
            getSinWave(interval: universalSize.width, amplitude: 200, baseline: 50 + universalSize.height/1.5)
                .foregroundColor(Color.accentColor.opacity(0.8))
                .offset(x: isAnimated ? -1*universalSize.width : 0)
                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimated)
            
            getSinWave(interval: universalSize.width*1.2, amplitude: 150, baseline: 50 + universalSize.height/1.5)
                .foregroundColor(Color.accentColor.opacity(0.6))
                .offset(x: isAnimated ? -1*(universalSize.width*1.2) : 0)
                .animation(Animation.linear(duration: 6).repeatForever(autoreverses: false), value: isAnimated)
            
            getSinWave(interval: universalSize.width*3, amplitude: 200, baseline: 95 + universalSize.height/1.5)
                .foregroundColor(Color.black.opacity(0.2))
                .offset(x: isAnimated ? -1*(universalSize.width*3) : 0)
                .animation(Animation.linear(duration: 4).repeatForever(autoreverses: false), value: isAnimated)
            
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if (useAnimation) {
                DispatchQueue.main.async {
                    self.isAnimated = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isAnimated = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isAnimated = true
        }
    }
    
    public func getSinWave(interval: CGFloat, amplitude: CGFloat = 100, baseline: CGFloat = UIScreen.main.bounds.height/2) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: baseline))
            path.addCurve(
                to: CGPoint(x: 1*interval, y: baseline),
                control1: CGPoint(x: interval * (0.35), y: amplitude + baseline),
                control2: CGPoint(x: interval * (0.65), y: -amplitude + baseline)
            )
            path.addCurve(
                to: CGPoint(x: 2*interval, y: baseline),
                control1: CGPoint(x: interval * (1.35), y: amplitude + baseline),
                control2: CGPoint(x: interval * (1.65), y: -amplitude + baseline)
            )
            path.addLine(to: CGPoint(x: 2*interval, y: universalSize.height))
            path.addLine(to: CGPoint(x: 0, y: universalSize.height))
        }
    }
}

