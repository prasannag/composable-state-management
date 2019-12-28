//
//  ContentView.swift
//  ComposableArchitectureSinglePage
//
//  Created by Prasanna Gopalakrishnan on 26/11/19.
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//


import SwiftUI

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(store: self.store)) {
          Text("Counter demo")
        }
        NavigationLink(destination: FavoritePrimesView(store: self.store)) {
          Text("Favorite primes")
        }
      }
      .navigationBarTitle("State management")
    }
  }
}

import Combine

struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var loggedInUser: User? = nil
  var activityFeed: [Activity] = []

  struct Activity {
    let timestamp: Date
    let type: ActivityType

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)

      var addedFavoritePrime: Int? {
        get {
          guard case let .addedFavoritePrime(value) = self else { return nil }
          return value
        }
        set {
          guard case .addedFavoritePrime = self, let newValue = newValue else { return }
          self = .addedFavoritePrime(newValue)
        }
      }

      var removedFavoritePrime: Int? {
        get {
          guard case let .removedFavoritePrime(value) = self else { return nil }
          return value
        }
        set {
          guard case .removedFavoritePrime = self, let newValue = newValue else { return }
          self = .removedFavoritePrime(newValue)
        }
      }
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

enum CounterAction {
  case decrTapped
  case incrTapped
}

enum PrimeModalAction {
  case saveFavoritePrimeTapped
  case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
  case deleteFavoritePrimes(IndexSet)

  var deleteFavoritePrimes: IndexSet? {
    get {
      guard case let .deleteFavoritePrimes(value) = self else { return nil }
      return value
    }
    set {
      guard case .deleteFavoritePrimes = self, let newValue = newValue else { return }
      self = .deleteFavoritePrimes(newValue)
    }
  }
}

enum AppAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)
  case favoritePrimes(FavoritePrimesAction)

  var counter: CounterAction? {
    get {
      guard case let .counter(value) = self else { return nil }
      return value
    }
    set {
      guard case .counter = self, let newValue = newValue else { return }
      self = .counter(newValue)
    }
  }

  var primeModal: PrimeModalAction? {
    get {
      guard case let .primeModal(value) = self else { return nil }
      return value
    }
    set {
      guard case .primeModal = self, let newValue = newValue else { return }
      self = .primeModal(newValue)
    }
  }

  var favoritePrimes: FavoritePrimesAction? {
    get {
      guard case let .favoritePrimes(value) = self else { return nil }
      return value
    }
    set {
      guard case .favoritePrimes = self, let newValue = newValue else { return }
      self = .favoritePrimes(newValue)
    }
  }
}

func counterReducer(state: inout Int, action: CounterAction) {
  switch action {
  case .decrTapped:
    state -= 1
    
  case .incrTapped:
    state += 1
  }
}

func primeModalReducer(state: inout AppState, action: PrimeModalAction) {
  switch action {
    case .saveFavoritePrimeTapped:
      state.favoritePrimes.append(state.count)
      
    case .removeFavoritePrimeTapped:
      state.favoritePrimes.removeAll(where: { $0 == state.count })
  }
}

func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
  switch action {
    
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.remove(at: index)
    }
  }
}

func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>)
  -> (inout GlobalValue, GlobalAction) -> Void {

  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return }
    reducer(&globalValue[keyPath: value], localAction)
  }
}

func activityFeed(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
  return { state, action in
    // do some computations with state and action
    switch action {
    case .counter:
      break

    case .primeModal(.saveFavoritePrimeTapped):
      state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
      
    case .primeModal(.removeFavoritePrimeTapped):
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
      
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet {
        state.activityFeed.append(
          .init(
            timestamp: Date(),
            type: .removedFavoritePrime(state.favoritePrimes[index])))
      }
    }
    reducer(&state, action)
    // inspect what happened to state
  }
}

let appReducer: (inout AppState, AppAction) -> Void = combine(
  pullback(counterReducer, value: \.count, action: \.counter),
  pullback(primeModalReducer, value: \.self, action: \.primeModal),
  pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

func combine<Value, Action>(
  _ reducers: (inout Value, Action) -> Void...)
  -> (inout Value, Action) -> Void {
    return { value, action in
      for reducer in reducers {
        reducer(&value, action)
      }
    }
}

final class Store<Value, Action>: ObservableObject {
  let reducer: (inout Value, Action) -> Void
  @Published var value: Value
  
  init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
    self.reducer = reducer
    self.value = initialValue
  }
  
  func send(_ action: Action) {
    self.reducer(&self.value, action)
  }
}


struct PrimeAlert: Identifiable {
  let prime: Int

  var id: Int { self.prime }
}

struct CounterView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  @State var isPrimeModalShown: Bool = false
  @State var alertNthPrime: PrimeAlert?
  @State var isNthPrimeButtonDisabled = false

  var body: some View {
    VStack {
      HStack {
        Button(action: { self.store.send(.counter(.decrTapped)) }) {
          Text("-")
        }
        Text("\(self.store.value.count)")
        Button(action: { self.store.send(.counter(.incrTapped)) }) {
          Text("+")
        }
      }
      Button(action: { self.isPrimeModalShown = true }) {
        Text("Is this prime?")
      }
      Button(action: self.nthPrimeButtonAction) {
        Text("What is the \(ordinal(self.store.value.count)) prime?")
      }
      .disabled(self.isNthPrimeButtonDisabled)
    }
    .font(.title)
    .navigationBarTitle("Counter demo")
    .sheet(isPresented: self.$isPrimeModalShown) {
      IsPrimeModalView(store: self.store)
    }
    .alert(item: self.$alertNthPrime) { alert in
      Alert(
        title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
        dismissButton: .default(Text("Ok"))
      )
    }
  }

  func nthPrimeButtonAction() {
    self.isNthPrimeButtonDisabled = true
    nthPrime(self.store.value.count) { prime in
      self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
      self.isNthPrimeButtonDisabled = false
    }
  }
}

struct IsPrimeModalView: View {
  @ObservedObject var store: Store<AppState, AppAction>

  var body: some View {
    VStack {
      if isPrime(self.store.value.count) {
        Text("\(self.store.value.count) is prime 🎉")
        if self.store.value.favoritePrimes.contains(self.store.value.count) {
          Button(action: {
            self.store.send(.primeModal(.removeFavoritePrimeTapped))
          }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: {
            self.store.send(.primeModal(.saveFavoritePrimeTapped))
          }) {
            Text("Save to favorite primes")
          }
        }

      } else {
        Text("\(self.store.value.count) is not prime :(")
      }

    }
  }
}

struct FavoritePrimesView: View {
  @ObservedObject var store: Store<AppState, AppAction>

  var body: some View {
    List {
      ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        self.store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
      }
    }
      .navigationBarTitle(Text("Favorite Primes"))
  }
}


//import PlaygroundSupport
//
//PlaygroundPage.current.liveView = UIHostingController(
//  rootView: ContentView(state: AppState())
////  rootView: CounterView()
//)



#if DEBUG
struct SettingsForm_Previews : PreviewProvider {
    static var previews: some View {
      ContentView(
        store: Store(
          initialValue: AppState(),
          reducer: activityFeed(appReducer)
        )
      )
    }
}
#endif
