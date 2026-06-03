import WidgetKit

struct CharacterWidgetEntry: TimelineEntry {
    let date: Date
    let character: CharacterWidgetData?
    let currentIndex: Int
    let totalCount: Int

    init(date: Date, character: CharacterWidgetData?, currentIndex: Int = 0, totalCount: Int = 0) {
        self.date = date
        self.character = character
        self.currentIndex = currentIndex
        self.totalCount = totalCount
    }
}
