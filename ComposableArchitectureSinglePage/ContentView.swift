//
//  ContentView.swift
//  ComposableArchitectureSinglePage
//
//  Created by Prasanna Gopalakrishnan on 26/11/19.
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//


import SwiftUI

struct ContentView: View {
  @ObservedObject var store: Store<AppState, CounterAction>
  
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

func counterReducer(state: AppState, action: CounterAction) -> AppState {
  var copy = state
  switch action {
  case .decrTapped:
    copy.count -= 1
  case .incrTapped:
    copy.count += 1
  }
  return copy
}

final class Store<Value, Action>: ObservableObject {
  let reducer: (Value, Action) -> Value
  @Published var value: Value
  
  init(initialValue: Value, reducer: @escaping (Value, Action) -> Value) {
    self.reducer = reducer
    self.value = initialValue
  }
  
  func send(_ action: Action) {
    self.value = self.reducer(self.value, action)
  }
}


struct PrimeAlert: Identifiable {
  let prime: Int

  var id: Int { self.prime }
}

struct CounterView: View {
  @ObservedObject var store: Store<AppState, CounterAction>
  @State var isPrimeModalShown: Bool = false
  @State var alertNthPrime: PrimeAlert?
  @State var isNthPrimeButtonDisabled = false

  var body: some View {
    VStack {
      HStack {
        Button(action: { self.store.send(.decrTapped) }) {
          Text("-")
        }
        Text("\(self.store.value.count)")
        Button(action: { self.store.send(.incrTapped) }) {
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
  @ObservedObject var store: Store<AppState, CounterAction>

  var body: some View {
    VStack {
      if isPrime(self.store.value.count) {
        Text("\(self.store.value.count) is prime 🎉")
        if self.store.value.favoritePrimes.contains(self.store.value.count) {
          Button(action: {
            self.store.value.favoritePrimes.removeAll(where: { $0 == self.store.value.count })
            self.store.value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(self.store.value.count)))
          }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: {
            self.store.value.favoritePrimes.append(self.store.value.count)
            self.store.value.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(self.store.value.count)))

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

struct FavoritePrimesState {
  var favoritePrimes: [Int]
  var activityFeed: [AppState.Activity]
}
extension AppState {
  var favoritePrimesState: FavoritePrimesState {
    get {
      FavoritePrimesState(
        favoritePrimes: self.favoritePrimes,
        activityFeed: self.activityFeed
      )
    }
    set {
      self.favoritePrimes = newValue.favoritePrimes
      self.activityFeed = newValue.activityFeed
    }
  }
}

struct FavoritePrimesView: View {
  @ObservedObject var store: Store<AppState, CounterAction>

  var body: some View {
    List {
      ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        for index in indexSet {
          let prime = self.store.value.favoritePrimes[index]
          self.store.value.favoritePrimes.remove(at: index)
          self.store.value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
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
      ContentView(store: Store(initialValue: AppState(), reducer: counterReducer))
    }
}
#endif
