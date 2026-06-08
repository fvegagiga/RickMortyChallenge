import Foundation
import SwiftUI
import UIKit
import XCTest
import SnapshotTestKit
@testable import RickMortyPersistImage

@MainActor
final class ScreenshotRegressionTests: XCTestCase {
    private static var retainedHosts: [UIViewController] = []
    private static var retainedWindows: [UIWindow] = []
    private let settledWaitNanoseconds: UInt64 = 250_000_000
    private let loadingWaitNanoseconds: UInt64 = 60_000_000

    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    func testCharactersList_content() async throws {
        let viewModel = CharactersListViewModel(
            getCharactersUseCase: CharactersUseCaseStub(outcome: .success(items: Fixtures.characters(count: 8))),
            appGroupStore: nil
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: charactersList(viewModel: viewModel),
            named: "CharactersList_Content",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testCharactersList_loading() async throws {
        let viewModel = CharactersListViewModel(
            getCharactersUseCase: CharactersUseCaseStub(outcome: .delayedSuccess(items: Fixtures.characters(count: 8), delayNanoseconds: 2_000_000_000)),
            appGroupStore: nil
        )
        let loadingTask = Task { await viewModel.loadInitial() }
        defer { loadingTask.cancel() }
        await Task.yield()

        try await assertSnapshot(
            of: charactersList(viewModel: viewModel),
            named: "CharactersList_Loading",
            waitNanoseconds: loadingWaitNanoseconds
        )
    }

    func testCharactersList_empty() async throws {
        let viewModel = CharactersListViewModel(
            getCharactersUseCase: CharactersUseCaseStub(outcome: .success(items: [])),
            appGroupStore: nil
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: charactersList(viewModel: viewModel),
            named: "CharactersList_Empty",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testCharactersList_error() async throws {
        let viewModel = CharactersListViewModel(
            getCharactersUseCase: CharactersUseCaseStub(outcome: .failure(ScreenshotError.sample)),
            appGroupStore: nil
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: charactersList(viewModel: viewModel),
            named: "CharactersList_Error",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testCharacterDetail_content() async throws {
        try await assertSnapshot(
            of: CharacterDetailContentBodyView(
                character: Fixtures.character(id: 1),
                cacheManager: DIContainer().imageCacheManager
            ),
            named: "CharacterDetail_Content",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testCharacterDetail_loading() async throws {
        try await assertSnapshot(
            of: LoadingView(),
            named: "CharacterDetail_Loading",
            waitNanoseconds: loadingWaitNanoseconds
        )
    }

    func testCharacterDetail_error() async throws {
        try await assertSnapshot(
            of: ErrorView(error: ScreenshotError.sample, onRetry: {}),
            named: "CharacterDetail_Error",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testLocationsList_content() async throws {
        let viewModel = LocationsListViewModel(
            getLocationsUseCase: LocationsUseCaseStub(outcome: .success(items: Fixtures.locations(count: 10)))
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: locationsList(viewModel: viewModel),
            named: "LocationsList_Content",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testLocationsList_loading() async throws {
        let viewModel = LocationsListViewModel(
            getLocationsUseCase: LocationsUseCaseStub(outcome: .delayedSuccess(items: Fixtures.locations(count: 10), delayNanoseconds: 2_000_000_000))
        )
        let loadingTask = Task { await viewModel.loadInitial() }
        defer { loadingTask.cancel() }
        await Task.yield()

        try await assertSnapshot(
            of: locationsList(viewModel: viewModel),
            named: "LocationsList_Loading",
            waitNanoseconds: loadingWaitNanoseconds
        )
    }

    func testLocationsList_empty() async throws {
        let viewModel = LocationsListViewModel(
            getLocationsUseCase: LocationsUseCaseStub(outcome: .success(items: []))
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: locationsList(viewModel: viewModel),
            named: "LocationsList_Empty",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testLocationsList_error() async throws {
        let viewModel = LocationsListViewModel(
            getLocationsUseCase: LocationsUseCaseStub(outcome: .failure(ScreenshotError.sample))
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: locationsList(viewModel: viewModel),
            named: "LocationsList_Error",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testEpisodesList_content() async throws {
        let viewModel = EpisodesListViewModel(
            getEpisodesUseCase: EpisodesUseCaseStub(outcome: .success(items: Fixtures.episodes(count: 10)))
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: episodesList(viewModel: viewModel),
            named: "EpisodesList_Content",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testEpisodesList_loading() async throws {
        let viewModel = EpisodesListViewModel(
            getEpisodesUseCase: EpisodesUseCaseStub(outcome: .delayedSuccess(items: Fixtures.episodes(count: 10), delayNanoseconds: 2_000_000_000))
        )
        let loadingTask = Task { await viewModel.loadInitial() }
        defer { loadingTask.cancel() }
        await Task.yield()

        try await assertSnapshot(
            of: episodesList(viewModel: viewModel),
            named: "EpisodesList_Loading",
            waitNanoseconds: loadingWaitNanoseconds
        )
    }

    func testEpisodesList_empty() async throws {
        let viewModel = EpisodesListViewModel(
            getEpisodesUseCase: EpisodesUseCaseStub(outcome: .success(items: []))
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: episodesList(viewModel: viewModel),
            named: "EpisodesList_Empty",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    func testEpisodesList_error() async throws {
        let viewModel = EpisodesListViewModel(
            getEpisodesUseCase: EpisodesUseCaseStub(outcome: .failure(ScreenshotError.sample))
        )
        await viewModel.loadInitial()

        try await assertSnapshot(
            of: episodesList(viewModel: viewModel),
            named: "EpisodesList_Error",
            waitNanoseconds: settledWaitNanoseconds
        )
    }

    private func assertSnapshot(
        of view: some View,
        named snapshotName: String,
        waitNanoseconds: UInt64
    ) async throws {
        let snapshotSize = CGSize(width: 390, height: 844)
        let host = UIHostingController(
            rootView: configured(view)
                .frame(width: snapshotSize.width, height: snapshotSize.height)
        )
        let window = UIWindow(frame: CGRect(origin: .zero, size: snapshotSize))

        host.loadViewIfNeeded()
        host.view.frame = window.bounds
        host.view.backgroundColor = .systemBackground
        host.overrideUserInterfaceStyle = .light
        window.rootViewController = host
        window.overrideUserInterfaceStyle = .light
        window.isHidden = false
        window.layoutIfNeeded()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        Self.retainedHosts.append(host)
        Self.retainedWindows.append(window)

        await Task.yield()
        try await Task.sleep(nanoseconds: waitNanoseconds)
        window.layoutIfNeeded()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        SnapshotTestKit.assertSnapshot(
            of: renderImage(from: host),
            named: snapshotName,
            record: ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1",
            file: #filePath,
            testName: name,
            line: #line
        )
    }

    private func renderImage(from viewController: UIViewController) -> UIImage {
        let bounds = CGRect(origin: .zero, size: viewController.view.bounds.size)
        let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: UIScreen.main.scale))
        format.scale = UIScreen.main.scale

        return autoreleasepool {
            UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                viewController.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
            }
        }
    }

    private func configured<Content: View>(_ view: Content) -> some View {
        view
            .environment(\.locale, Locale(identifier: "en_US_POSIX"))
            .environment(\.sizeCategory, .medium)
            .environment(\.colorScheme, .light)
            .environment(\.layoutDirection, .leftToRight)
            .preferredColorScheme(.light)
    }

    private func charactersList(viewModel: CharactersListViewModel) -> some View {
        CharactersListView(viewModel: viewModel)
            .environmentObject(DIContainer())
            .environmentObject(AppRouter())
    }

    private func characterDetail(viewModel: CharacterDetailViewModel) -> some View {
        CharacterDetailView(viewModel: viewModel)
        .environmentObject(DIContainer())
        .environmentObject(AppRouter())
    }

    private func locationsList(viewModel: LocationsListViewModel) -> some View {
        LocationsListView(viewModel: viewModel)
    }

    private func episodesList(viewModel: EpisodesListViewModel) -> some View {
        EpisodesListView(viewModel: viewModel)
    }
}

private enum ListOutcome<T> {
    case success(items: [T])
    case delayedSuccess(items: [T], delayNanoseconds: UInt64)
    case failure(any Error)
}

private enum DetailOutcome<T> {
    case success(T)
    case delayedSuccess(T, delayNanoseconds: UInt64)
    case failure(any Error)
}

@MainActor
private final class CharactersUseCaseStub: GetCharactersUseCaseProtocol {
    let outcome: ListOutcome<CharacterEntity>
    init(outcome: ListOutcome<CharacterEntity>) { self.outcome = outcome }

    func execute(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        switch outcome {
        case .success(let items):
            return PagedResult(items: items, hasNextPage: false, totalCount: items.count)
        case .delayedSuccess(let items, let delay):
            try await Task.sleep(nanoseconds: delay)
            return PagedResult(items: items, hasNextPage: false, totalCount: items.count)
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
private final class CharacterDetailUseCaseStub: GetCharacterDetailUseCaseProtocol {
    let outcome: DetailOutcome<CharacterEntity>
    init(outcome: DetailOutcome<CharacterEntity>) { self.outcome = outcome }

    func execute(id: Int) async throws -> CharacterEntity {
        switch outcome {
        case .success(let value):
            return value
        case .delayedSuccess(let value, let delay):
            try await Task.sleep(nanoseconds: delay)
            return value
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
private final class LocationsUseCaseStub: GetLocationsUseCaseProtocol {
    let outcome: ListOutcome<LocationEntity>
    init(outcome: ListOutcome<LocationEntity>) { self.outcome = outcome }

    func execute(page: Int) async throws -> PagedResult<LocationEntity> {
        switch outcome {
        case .success(let items):
            return PagedResult(items: items, hasNextPage: false, totalCount: items.count)
        case .delayedSuccess(let items, let delay):
            try await Task.sleep(nanoseconds: delay)
            return PagedResult(items: items, hasNextPage: false, totalCount: items.count)
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
private final class EpisodesUseCaseStub: GetEpisodesUseCaseProtocol {
    let outcome: ListOutcome<EpisodeEntity>
    init(outcome: ListOutcome<EpisodeEntity>) { self.outcome = outcome }

    func execute(page: Int) async throws -> PagedResult<EpisodeEntity> {
        switch outcome {
        case .success(let items):
            return PagedResult(items: items, hasNextPage: false, totalCount: items.count)
        case .delayedSuccess(let items, let delay):
            try await Task.sleep(nanoseconds: delay)
            return PagedResult(items: items, hasNextPage: false, totalCount: items.count)
        case .failure(let error):
            throw error
        }
    }
}

private enum Fixtures {
    static func character(id: Int) -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: "Character \(id)",
            status: id.isMultiple(of: 2) ? .alive : .unknown,
            species: "Human",
            type: "",
            gender: .male,
            originName: "Earth (C-137)",
            currentLocationName: "Citadel of Ricks",
            imageURL: nil,
            episodeURLs: [],
            created: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    static func characters(count: Int) -> [CharacterEntity] { (1...count).map(character(id:)) }

    static func location(id: Int) -> LocationEntity {
        LocationEntity(
            id: id,
            name: "Location \(id)",
            type: "Planet",
            dimension: "Dimension C-\(100 + id)",
            residentURLs: [],
            created: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    static func locations(count: Int) -> [LocationEntity] { (1...count).map(location(id:)) }

    static func episode(id: Int) -> EpisodeEntity {
        EpisodeEntity(
            id: id,
            name: "Episode \(id)",
            airDate: "December \(id), 2013",
            episodeCode: "S01E\(String(format: "%02d", id))",
            characterURLs: [],
            created: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    static func episodes(count: Int) -> [EpisodeEntity] { (1...count).map(episode(id:)) }
}

private enum ScreenshotError: Error, LocalizedError {
    case sample
    var errorDescription: String? { "Screenshot failure stub" }
}
