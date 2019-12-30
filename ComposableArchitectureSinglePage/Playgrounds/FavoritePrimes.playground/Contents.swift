import UIKit
import ComposableArchitecture
//import Counter
import FavoritePrimes
//import PrimeModal
import SwiftUI
import PlaygroundSupport

//PlaygroundPage.current.liveView = UIHostingController(
//  rootView: CounterView(
//    store: Store<CounterViewState, CounterViewAction>(
//      initialValue: (10000000, [2, 5, 7]),
//      reducer: counterViewReducer
//    )
//  )
//)

//PlaygroundPage.current.liveView = UIHostingController(
//  rootView: IsPrimeModalView(
//    store: Store<PrimeModalState, PrimeModalAction>(
//      initialValue: (3, [2, 5, 7]),
//      reducer: primeModalReducer
//    )
//  )
//)

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

//let store = Store<Int, Void>(initialValue: 0, reducer: { count, _ in count += 1 })
//
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//
//store.value
//
//let newStore = store.view { $0 }
//newStore.value
//
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.value
//store.value
//
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.value
//newStore.value
