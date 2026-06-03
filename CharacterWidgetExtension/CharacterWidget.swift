import WidgetKit
import SwiftUI

struct CharacterWidget: Widget {
    let kind: String = "CharacterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CharacterWidgetProvider()) { entry in
            CharacterWidgetView(entry: entry)
        }
        .configurationDisplayName("Rick & Morty Character")
        .description("Navigate through Rick & Morty characters.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
