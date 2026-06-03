import WidgetKit

struct CharacterWidgetProvider: TimelineProvider {
    private let store: AppGroupStoreProtocol

    init(store: AppGroupStoreProtocol = AppGroupStore()) {
        self.store = store
    }

    func placeholder(in context: Context) -> CharacterWidgetEntry {
        CharacterWidgetEntry(date: .now, character: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CharacterWidgetEntry) -> Void) {
        completion(CharacterWidgetEntry(date: .now, character: store.currentCharacter()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CharacterWidgetEntry>) -> Void) {
        let entry = CharacterWidgetEntry(date: .now, character: store.currentCharacter())
        let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(refresh))
        completion(timeline)
    }
}
