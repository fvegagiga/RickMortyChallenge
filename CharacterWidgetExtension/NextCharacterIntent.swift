import AppIntents
import WidgetKit

struct NextCharacterIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Character"

    func perform() async throws -> some IntentResult {
        let store = AppGroupStore()
        let total = store.totalCount()
        guard total > 0 else { return .result() }
        let next = (store.currentIndex() + 1) % total
        store.setCurrentIndex(next)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
