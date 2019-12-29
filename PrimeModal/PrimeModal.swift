//
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

public enum PrimeModalAction {
  case saveFavoritePrimeTapped
  case removeFavoritePrimeTapped
}


public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) {
  switch action {
    case .saveFavoritePrimeTapped:
      state.favoritePrimes.append(state.count)
      
    case .removeFavoritePrimeTapped:
      state.favoritePrimes.removeAll(where: { $0 == state.count })
  }
}

public struct IsPrimeModalView: View {
  @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
  
  public init(store: Store<PrimeModalState, PrimeModalAction>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      if isPrime(self.store.value.count) {
        Text("\(self.store.value.count) is prime 🎉")
        if self.store.value.favoritePrimes.contains(self.store.value.count) {
          Button(action: {
            self.store.send(.removeFavoritePrimeTapped)
          }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: {
            self.store.send(.saveFavoritePrimeTapped)
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

public func isPrime (_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}
