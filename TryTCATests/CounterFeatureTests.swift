//
//  CounterFeatureTests.swift
//  TryTCATests
//
//  Created by Byeonghak Kang on 1/4/24.
//

import XCTest
import ComposableArchitecture

@MainActor
final class CounterFeatureTests: XCTestCase {
    func testCounter() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }

    func testTiner() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }

        await store.receive(\.timerTick, timeout: 20_000_000_000) {
            $0.count = 1
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
}
