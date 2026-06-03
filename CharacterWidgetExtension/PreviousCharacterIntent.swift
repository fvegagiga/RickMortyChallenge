import AppIntents
import WidgetKit

struct PreviousCharacterIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Character"

    func perform() async throws -> some IntentResult {
        let store = AppGroupStore()
        let total = store.totalCount()
        guard total > 0 else { return .result() }
        let previous = (store.currentIndex() - 1 + total) % total
        store.setCurrentIndex(previous)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
