import UIKit
import ComposableArchitecture
import FavoritePrimes
import PlaygroundSupport
import SwiftUI

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
