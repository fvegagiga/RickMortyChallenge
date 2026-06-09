import SwiftUI

extension Font {
    enum DS {
        static let largeTitle  = Font.largeTitle.bold()
        static let title       = Font.title2.bold()
        static let headline    = Font.headline
        static let subheadline = Font.subheadline
        static let body        = Font.body
        static let caption     = Font.caption
        static let caption2    = Font.caption2
        static let badge       = Font.system(size: 11, weight: .semibold, design: .rounded)
    }
}
