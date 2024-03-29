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

    func testTimer() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }

        await store.receive(\.timerTick, timeout: .seconds(2)) {
            $0.count = 1
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }

    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number." }
        }

        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}

extension UInt64 {
    static func seconds(_ seconds: UInt) -> Self {
        UInt64(seconds) * 1_000_000_000
    }
}
