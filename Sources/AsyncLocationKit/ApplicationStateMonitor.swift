//
//  ApplicationStateMonitor.swift
//  AsyncLocationKit
//
//  Created by David Whetstone on 11/28/22.
//

import Foundation

@MainActor
class ApplicationStateMonitor {
    private(set) var hasResignedActive = false

    private var hasResignedActiveTask: Task<Void, Never>?
    private var hasBecomeActiveTask: Task<Void, Never>?

    func startMonitoringApplicationState() {
        guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
        startMonitoringHasResignedActive()
        startMonitoringHasBecomeActive()
    }

    func stopMonitoringApplicationState() {
        guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return }
        stopMonitoringHasResignedActive()
        stopMonitoringHasBecomeActive()
    }

    func hasResignedActive() async -> Bool {
        guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return false }
        var iter = hasResignedActiveSequence.makeAsyncIterator()
        return await iter.next() != nil
    }

    func hasBecomeActive() async -> Bool {
        guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return false }
        var iter = hasBecomeActiveSequence.makeAsyncIterator()
        return await iter.next() != nil
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    private func startMonitoringHasResignedActive() {
        guard hasResignedActiveTask == nil else { return }

        hasResignedActiveTask = Task {
            for await _ in self.hasResignedActiveSequence {
                if Task.isCancelled { break }
                self.hasResignedActive = true
                self.stopMonitoringHasResignedActive()
            }
        }
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    private func startMonitoringHasBecomeActive() {
        guard hasBecomeActiveTask == nil else { return }

        hasBecomeActiveTask = Task {
            for await _ in self.hasBecomeActiveSequence {
                if Task.isCancelled { break }
                self.stopMonitoringHasBecomeActive()
            }
        }
    }

    private func stopMonitoringHasResignedActive() {
        hasResignedActiveTask?.cancel()
        hasResignedActiveTask = nil
    }

    private func stopMonitoringHasBecomeActive() {
        hasBecomeActiveTask?.cancel()
        hasBecomeActiveTask = nil
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    private var hasResignedActiveSequence: AsyncMapSequence<NotificationCenter.Notifications, Bool> {
        _hasResignedActiveSequence as! AsyncMapSequence<NotificationCenter.Notifications, Bool>
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    private var hasBecomeActiveSequence: AsyncMapSequence<NotificationCenter.Notifications, Bool> {
        _hasBecomeActiveSequence as! AsyncMapSequence<NotificationCenter.Notifications, Bool>
    }

    // We unfortunately need these backing variables since properties cannot be declared conditionally available

    private var _hasResignedActiveSequence: Any? = {
        guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return nil }
        return NotificationCenter.default.notifications(named: NotificationNamesConstants.willResignActiveName).map { _ in true }
    }()

    private var _hasBecomeActiveSequence: Any? = {
        guard #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) else { return nil }
        return NotificationCenter.default.notifications(named: NotificationNamesConstants.didBecomeActiveName).map { _ in true }
    }()
}
