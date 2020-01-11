//
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

import Combine
import ComposableArchitecture
import SwiftUI

public enum FavoritePrimesAction: Equatable {
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
    return [
      Current.fileClient.save("favorite-primes.json", try! JSONEncoder().encode(state))
        .fireAndForget()
    ]
    
  case .loadButtonTapped:
    return [
      Current.fileClient.load("favorite-primes.json")
        .compactMap { $0 }
        .decode(type: [Int].self, decoder: JSONDecoder())
        .catch { error in Empty(completeImmediately: true) }
        .map(FavoritePrimesAction.favoritePrimesLoaded)
        .eraseToEffect()
    ]
  }
}

func absurd<A>(_ never: Never) -> A { }

extension Publisher where Output == Never, Failure == Never {
  func fireAndForget<A>() -> Effect<A> {
    return self.map(absurd).eraseToEffect()
  }
}

struct FileClient {
  var load: (String) -> Effect<Data?>
  var save: (String, Data) -> Effect<Never>
}

extension FileClient {
  static let live = FileClient(
    load: { fileName -> Effect<Data?> in
      .sync {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let favoritePrimesURL = documentsURL.appendingPathComponent(fileName)
        return try? Data(contentsOf: favoritePrimesURL)
      }
  }) { (fileName, data) -> Effect<Never> in
    .fireAndForget {
      let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
      let documentsURL = URL(fileURLWithPath: documentsPath)
      let favoritePrimesURL = documentsURL.appendingPathComponent(fileName)
      try! data.write(to: favoritePrimesURL)
    }
  }
}


struct FavoritePrimesEnvironment {
  var fileClient: FileClient
}

extension FavoritePrimesEnvironment {
  static let live = FavoritePrimesEnvironment(
    fileClient: .live
  )
  
  static let mock = FavoritePrimesEnvironment(
    fileClient: FileClient(
      load: { _ in Effect<Data?>.sync {
        try! JSONEncoder().encode([2, 31])
        }
    },
      save: { _, _ in .fireAndForget { } }
    )
  )
}

var Current = FavoritePrimesEnvironment.live

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
