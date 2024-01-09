//
//  ContactsFeature.swift
//  TryTCA
//
//  Created by Byeonghak Kang on 1/9/24.
//

import SwiftUI
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
    let id = UUID()
    var name: String
}

@Reducer
struct ContactsFeature {
    struct State: Equatable {
        @PresentationState var addContact: AddContactFeature.State?
        @PresentationState var alert: AlertState<Action.Alert>?
        var contacts: IdentifiedArrayOf<Contact> = []
    }

    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>)
        case deleteButtonTapped(id: Contact.ID)

        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactFeature.State(
                    contact: Contact(name: "")
                )
                return .none


            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                state.contacts.append(contact)
                return .none

            case .addContact:
                return .none

            case let .deleteButtonTapped(id: id):
                state.alert = AlertState {
                    TextState("Sure?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                        TextState("Delete")
                    }
                }
                return .none

            case let .alert(.presented(.confirmDeletion(id: id))):
                state.contacts.remove(id: id)
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct ContactsView: View {
    let store: StoreOf<ContactsFeature>

    var body: some View {
        NavigationView {
            WithViewStore(store, observe: \.contacts) { viewStore in
                List {
                    ForEach(viewStore.state) { contact in
                        HStack {
                            Text(contact.name)
                            Spacer()
                            Button {
                                viewStore.send(.deleteButtonTapped(id: contact.id))
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            viewStore.send(.addButtonTapped)
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
            }
        }
        .sheet(
            store: store.scope(
                state: \.$addContact,
                action: \.addContact
            )
        ) { addContactStore in
            NavigationView {
                AddContactView(store: addContactStore)
            }
        }
        .alert(
            store: store.scope(
                state: \.$alert,
                action: \.alert
            )
        )
    }
}

#Preview {
    ContactsView(
        store: Store(initialState: ContactsFeature.State(
            contacts: [
                Contact(name: "Tester 1"),
                Contact(name: "Tester 2"),
                Contact(name: "Tester 3"),
            ]
        )) {
            ContactsFeature()
        }
    )
}
