//
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public enum FavoritePrimesAction {
  case deleteFavoritePrimes(IndexSet)
  case favoritePrimesLoaded([Int])
  case saveButtonTapped
  case loadButtonTapped
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.remove(at: index)
    }
    return[]
    
  case let .favoritePrimesLoaded(favoritePrimes):
    state = favoritePrimes
    return []
    
  case .saveButtonTapped:
    return [saveEffect(favoritePrimes: state)]
    
  case .loadButtonTapped:
    return [loadEffect]
  }
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
  return {
    let data = try! JSONEncoder().encode(favoritePrimes)
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsURL = URL(fileURLWithPath: documentsPath)
    let favoritePrimesURL = documentsURL.appendingPathComponent("favorite-primes.json")
    try! data.write(to: favoritePrimesURL)
    return nil
  }
}

private let loadEffect: Effect<FavoritePrimesAction> = {
  let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  let documentsURL = URL(fileURLWithPath: documentsPath)
  let favoritePrimesURL = documentsURL.appendingPathComponent("favorite-primes.json")
  guard
    let data = try? Data(contentsOf: favoritePrimesURL),
    let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return nil }
  return .favoritePrimesLoaded(favoritePrimes)
}

public struct FavoritePrimesView: View {
  @ObservedObject var store: Store<[Int], FavoritePrimesAction>
  
  public init(store: Store<[Int], FavoritePrimesAction>) {
    self.store = store
  }

  public var body: some View {
    List {
      ForEach(self.store.value, id: \.self) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        self.store.send(.deleteFavoritePrimes(indexSet))
      }
    }
    .navigationBarTitle(Text("Favorite Primes"))
    .navigationBarItems(trailing:
      HStack {
        Button("Save") {
          self.store.send(.saveButtonTapped)
        }
        
        Button("Load") {
          self.store.send(.loadButtonTapped)
        }
      }
    )
  }
}
