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
        var contacts: IdentifiedArrayOf<Contact> = []
        @PresentationState var destination:  Destination.State?
    }

    enum Action {
        case addButtonTapped
        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)

        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addContact(
                    AddContactFeature.State(
                        contact: Contact(name: "")
                    )
                )
                return .none

            case  let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                state.contacts.append(contact)
                return .none

            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.contacts.remove(id: id)
                return .none

            case .destination:
                return .none

            case let .deleteButtonTapped(id: id):
                state.destination = .alert(
                    AlertState {
                        TextState("Sure?")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                            TextState("Delete")
                        }
                    }
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
}

extension ContactsFeature {
    @Reducer
    struct Destination {
        enum State: Equatable {
            case addContact(AddContactFeature.State)
            case alert(AlertState<ContactsFeature.Action.Alert>)
        }

        enum Action {
            case addContact(AddContactFeature.Action)
            case alert(ContactsFeature.Action.Alert)
        }

        var body: some ReducerOf<Self> {
            Scope(state: \.addContact, action: \.addContact) {
                AddContactFeature()
            }
        }
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
                state: \.$destination.addContact,
                action: \.destination.addContact
            )
        ) { addContactStore in
            NavigationView {
                AddContactView(store: addContactStore)
            }
        }
        .alert(
            store: store.scope(
                state: \.$destination.alert,
                action: \.destination.alert
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
