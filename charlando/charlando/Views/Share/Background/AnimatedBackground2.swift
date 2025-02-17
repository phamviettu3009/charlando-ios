//
//  AnimatedBackground2.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 21/04/2024.
//

import Foundation
import SwiftUI

struct AnimatedBackground2: View {
    private enum AnimationProperties {
        static let animationSpeed: Double = 4
        static let timerDuration: TimeInterval = 3
        static let blurRadius: CGFloat = 130
    }
    
    @State private var timer = Timer.publish(every: AnimationProperties.timerDuration, on: .main, in: .common).autoconnect()
    
    @ObservedObject private var animator = CircleAnimator(colors: GradientColors.all)
    
    var timeText: some View {
        Text("11:23")
            .font(.system(size: 88.0, weight: .medium, design: .rounded))
            .padding(.top, 50)
    }
    
    var dateText: some View {
        Text("Tuesday, 18 April")
            .font(.system(size: 24, weight: .semibold, design: .rounded))
    }
    
    var body: some View {
        ZStack {
            ZStack {
                ForEach(animator.circles) { circle in
                    MovingCircle(originOffset: circle.position)
                        .foregroundColor(circle.color)
                }
            }
            .blur(radius: AnimationProperties.blurRadius)
            
//            VStack {
//                timeText
//                    .foregroundColor(.white)
//                    .blendMode(.difference)
//                    .overlay(timeText.blendMode(.hue))
//                    .overlay(timeText.foregroundColor(.gray).blendMode(.overlay))
//                
//                dateText
//                    .foregroundColor(.white)
//                    .blendMode(.difference)
//                    .overlay(dateText.blendMode(.hue))
//                    .overlay(dateText.foregroundColor(.gray).blendMode(.overlay))
//                
//                Spacer()
//            }
        }
//        .background(GradientColors.backgroundColor)
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onAppear {
            animateCircles()
            timer = Timer.publish(every: AnimationProperties.timerDuration, on: .main, in: .common).autoconnect()
        }
        .onReceive(timer) { _ in
            animateCircles()
        }
    }
    private func animateCircles() {
        withAnimation(.easeInOut(duration: AnimationProperties.animationSpeed)) {
            animator.animate()
        }
    }
}

private enum GradientColors {
    static var all: [Color] {
        [
            Color.blue,
            Color.white
        ]
    }
    
    static var backgroundColor: Color {
        Color(#colorLiteral(
            red: 0.003799867816,
            green: 0.01174801588,
            blue: 0.07808648795,
            alpha: 1
        ))
    }
}

private struct MovingCircle: Shape {
    var originOffset: CGPoint
    
    var animatableData: CGPoint.AnimatableData {
        get { originOffset.animatableData }
        set { originOffset.animatableData = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let adjustedX = rect.width * originOffset.x
        let adjustedY = rect.height * originOffset.y
        let smallestDimension = min(rect.width, rect.height)
        
        path.addArc(center: CGPoint(x: adjustedX, y: adjustedY), radius: smallestDimension, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        
        return path
    }
}

private class CircleAnimator: ObservableObject {
    class Circle: Identifiable {
        internal init(position: CGPoint, color: Color) {
            self.position = position
            self.color = color
        }
        var position: CGPoint
        let id = UUID().uuidString
        let color: Color
    }
    
    @Published private(set) var circles: [Circle] = []
    
    init(colors: [Color]) {
        circles = colors.map({color in
            Circle(position: CircleAnimator.generateRadomPosition(), color: color)
        })
    }
    
    func animate() {
        objectWillChange.send()
        for circle in circles {
            circle.position = CircleAnimator.generateRadomPosition()
        }
    }
    
    static func generateRadomPosition() -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1))
    }
}
