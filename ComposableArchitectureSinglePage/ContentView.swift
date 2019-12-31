//
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//


import Combine
import ComposableArchitecture
import Counter
import FavoritePrimes
import SwiftUI

struct AppState {
  var alertNthPrime: PrimeAlert? = nil
  var count = 0
  var favoritePrimes: [Int] = []
  var isNthPrimeButtonDisabled: Bool = false
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

enum AppAction {
  case counterView(CounterViewAction)
  case favoritePrimes(FavoritePrimesAction)

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

  var counterView: CounterViewAction? {
    get {
      guard case let .counterView(value) = self else { return nil }
      return value
    }
    set {
      guard case .counterView = self, let newValue = newValue else { return }
      self = .counterView(newValue)
    }
  }
}

extension AppState {
  var counterView: CounterViewState {
    get {
      CounterViewState(
        alertNthPrime: self.alertNthPrime,
        count: self.count,
        favoritePrimes: self.favoritePrimes,
        isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled
      )
    }
    set {
      self.alertNthPrime = newValue.alertNthPrime
      self.count = newValue.count
      self.favoritePrimes = newValue.favoritePrimes
      self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
    }
  }
}

let appReducer: Reducer<AppState, AppAction> = combine(
  pullback(counterViewReducer, value: \.counterView, action: \.counterView),
  pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

func activityFeed(
  _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
  return { state, action in
    // do some computations with state and action
    switch action {
    case .counterView(.counter),
         .favoritePrimes(.favoritePrimesLoaded),
         .favoritePrimes(.loadButtonTapped),
         .favoritePrimes(.saveButtonTapped):
      break

    case .counterView(.primeModal(.saveFavoritePrimeTapped)):
      state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
      
    case .counterView(.primeModal(.removeFavoritePrimeTapped)):
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
      
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet {
        state.activityFeed.append(
          .init(
            timestamp: Date(),
            type: .removedFavoritePrime(state.favoritePrimes[index])))
      }
    }
    return reducer(&state, action)
    // inspect what happened to state
  }
}

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink(
          "Counter demo",
          destination: CounterView(
            store: self.store.view(
              value: { $0.counterView },
              action: { .counterView($0) }
            )
          )
        )
        NavigationLink(
          "Favorite primes",
          destination: FavoritePrimesView(
            store: self.store.view(
              value: { $0.favoritePrimes },
              action: { .favoritePrimes($0) }
            )
          )
        )
      }
      .navigationBarTitle("State management")
    }
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
          reducer: with(appReducer,
                        compose(
                          logging,
                          activityFeed
            )
          )
        )
      )
    }
}
#endif
