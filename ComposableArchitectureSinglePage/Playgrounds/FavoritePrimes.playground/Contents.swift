//import UIKit
import ComposableArchitecture
@testable import FavoritePrimes
import PlaygroundSupport
import SwiftUI

Current = .mock

Current.fileClient.load = { _ in
  Effect.sync {
    try! JSONEncoder().encode(Array(1...100))
  }
}

PlaygroundPage.current.liveView = UIHostingController(
  rootView: NavigationView {
    FavoritePrimesView(
      store: Store<[Int], FavoritePrimesAction>(
        initialValue: [2, 3, 5, 7],
        reducer: favoritePrimesReducer
      )
    )
  }
)
