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
    static let store = Store(initialState: AppFeature.State(
        tab3: ContactsFeature.State(
            contacts: [
                Contact(name: "Tester 1"),
                Contact(name: "Tester 2"),
                Contact(name: "Tester 3"),
            ]
        )
    )) {
        AppFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
