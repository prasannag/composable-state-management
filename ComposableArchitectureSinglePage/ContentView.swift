//
//  ContentView.swift
//  ComposableArchitectureSinglePage
//
//  Created by Prasanna Gopalakrishnan on 26/11/19.
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//


import SwiftUI

struct ContentView: View {
  @ObservedObject var state: AppState

  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: self.state)) {
          Text("Counter demo")
        }
        NavigationLink(destination: FavoritePrimesView(state: self.$state.favoritePrimesState)) {
          Text("Favorite primes")
        }
      }
      .navigationBarTitle("State management")
    }
  }
}

//BindableObject

import Combine

class AppState: ObservableObject {
  @Published var count = 0
  @Published var favoritePrimes: [Int] = []
  @Published var loggedInUser: User? = nil
  @Published var activityFeed: [Activity] = []

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

struct PrimeAlert: Identifiable {
  let prime: Int

  var id: Int { self.prime }
}

struct CounterView: View {
  @ObservedObject var state: AppState
  @State var isPrimeModalShown: Bool = false
  @State var alertNthPrime: PrimeAlert?
  @State var isNthPrimeButtonDisabled = false

  var body: some View {
    VStack {
      HStack {
        Button(action: { self.state.count -= 1 }) {
          Text("-")
        }
        Text("\(self.state.count)")
        Button(action: { self.state.count += 1 }) {
          Text("+")
        }
      }
      Button(action: { self.isPrimeModalShown = true }) {
        Text("Is this prime?")
      }
      Button(action: self.nthPrimeButtonAction) {
        Text("What is the \(ordinal(self.state.count)) prime?")
      }
      .disabled(self.isNthPrimeButtonDisabled)
    }
    .font(.title)
    .navigationBarTitle("Counter demo")
    .sheet(isPresented: self.$isPrimeModalShown) {
      IsPrimeModalView(state: self.state)
    }
    .alert(item: self.$alertNthPrime) { alert in
      Alert(
        title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
        dismissButton: .default(Text("Ok"))
      )
    }
  }

  func nthPrimeButtonAction() {
    self.isNthPrimeButtonDisabled = true
    nthPrime(self.state.count) { prime in
      self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
      self.isNthPrimeButtonDisabled = false
    }
  }
}

struct IsPrimeModalView: View {
  @ObservedObject var state: AppState

  var body: some View {
    VStack {
      if isPrime(self.state.count) {
        Text("\(self.state.count) is prime 🎉")
        if self.state.favoritePrimes.contains(self.state.count) {
          Button(action: {
            self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })
            self.state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(self.state.count)))
          }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: {
            self.state.favoritePrimes.append(self.state.count)
            self.state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(self.state.count)))

          }) {
            Text("Save to favorite primes")
          }
        }

      } else {
        Text("\(self.state.count) is not prime :(")
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
  @Binding var state: FavoritePrimesState

  var body: some View {
    List {
      ForEach(self.state.favoritePrimes, id: \.self) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        for index in indexSet {
          let prime = self.state.favoritePrimes[index]
          self.state.favoritePrimes.remove(at: index)
          self.state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
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
        ContentView(state: AppState())
    }
}
#endif
