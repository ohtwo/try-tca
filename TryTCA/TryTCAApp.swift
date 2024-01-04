//
//  TryTCAApp.swift
//  TryTCA
//
//  Created by Byeonghak Kang on 1/4/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TryTCAApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            CounterView(store: Self.store)
        }
    }
}
