//
//  ExtensionView.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 21/11/2023.
//

import Foundation
import SwiftUI
import PhotosUI

extension View {
    func searchableCustom(isHidden: Bool, text: Binding<String>, prompt: LocalizedStringKey) -> some View {
        if isHidden {
            return AnyView(self)
        } else {
            return AnyView(self.searchable(text: text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt))
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func impactOccurred() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

extension LocalizedStringKey {
    func setLocale(value: String) -> LocalizedStringKey {
        return LocalizedStringKey(value)
    }
    
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
    
    func stringValue(locale: Locale = Locale.init(identifier: APIManager.language)) -> String {
        return .localizedString(for: self.stringKey ?? "", locale: locale)
    }
}

extension String {
    static func localizedString(for key: String, locale: Locale = .current) -> String {
        let language = locale.languageCode
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
    
    func asDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: self)!
    }
}

extension String? {
    func orEmpty() -> String {
        if self == nil {
            return ""
        }
        return self!
    }
}

extension Date {
    func asStringDate(dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

extension Data {
    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = (
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
            a = 255
        case 6: // RGB (24-bit)
            (r, g, b) = (
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
            a = 255
        default:
            (r, g, b, a) = (0, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func getDeviceOS() async -> String {
    let os = await UIDevice.current.userInterfaceIdiom
    switch os {
    case .phone:
        return "iOS"
    case .pad:
        return "iPadOS"
    case .vision:
        return "visionOS"
    case .mac:
        return "macOS"
    default:
        return "unknown"
    }
}

struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
