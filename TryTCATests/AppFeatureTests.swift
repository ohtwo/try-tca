//
//  AppFeatureTests.swift
//  TryTCATests
//
//  Created by Byeonghak Kang on 1/5/24.
//

import XCTest
import ComposableArchitecture

@MainActor
final class AppFeatureTests: XCTestCase {
    func testIncrementInFirstTab() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.tab1(.incrementButtonTapped)) {
            $0.tab1.count = 1
        }

    }
}
