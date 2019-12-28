//
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

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
