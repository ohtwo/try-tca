//
//  CounterFeature.swift
//  TryTCA
//
//  Created by Byeonghak Kang on 1/4/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterFeature {
    struct State: Equatable {
        var count: Int = 0
        var fact: String?
        var isLoading: Bool = false
        var isTimerRunning: Bool = false
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case toggleTimerButtonTapped
        case timerTick
    }

    enum CancelID {
        case timer
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none

            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none

            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true

                return .run { [count = state.count] send in
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    await send(.factResponse(fact))
                }

            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none

            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()

                guard state.isTimerRunning else {
                    return .cancel(id: CancelID.timer)
                }

                return .run { send in
                    while true {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)

            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            }
        }
    }
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)

                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(viewStore.isTimerRunning ? "Stop timer" : "Start timer") {
                    viewStore.send(.toggleTimerButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .cornerRadius(10)

                Button("Fact") {
                    viewStore.send(.factButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .cornerRadius(10)

                if viewStore.isLoading {
                    ProgressView()
                } else if let fact = viewStore.fact {
                    Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
        }
    )
}
