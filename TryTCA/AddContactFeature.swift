//
//  AddContactFeature.swift
//  TryTCA
//
//  Created by Byeonghak Kang on 1/9/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AddContactFeature {
    struct State: Equatable {
        var contact: Contact
    }

    enum Action {
        case cancelButtonTapped
        case saveButtonTapped
        case setName(String)

        case delegate(Delegate)
        enum Delegate: Equatable {
            case saveContact(Contact)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }

            case .saveButtonTapped:
                return .run { [contact = state.contact] send in
                    await send(.delegate(.saveContact(contact)))
                    await self.dismiss()
                }

            case let .setName(name):
                state.contact.name = name
                return .none
            
            case .delegate:
                return .none
            }
        }
    }
}

struct AddContactView: View {
    let store: StoreOf<AddContactFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                TextField("Name", text: viewStore.binding(get: \.contact.name, send: { .setName($0) }))
                Button("Save") {
                    viewStore.send(.saveButtonTapped)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Cancel") {
                        viewStore.send(.cancelButtonTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddContactView(
            store: Store(initialState: AddContactFeature.State(
                contact: Contact(name: "")
            )) {
                AddContactFeature()
            }
        )
    }
}
