import UIKit
import ComposableArchitecture
@testable import Counter
import PlaygroundSupport
import SwiftUI


Current = .mock
Current.nthPrime = { _ in .sync { 53432134542 }}

PlaygroundPage.current.liveView = UIHostingController(
  rootView: CounterView(
    store: Store<CounterViewState, CounterViewAction>(
      initialValue: CounterViewState(
        alertNthPrime: nil,
        count: 0,
        favoritePrimes: [],
        isNthPrimeButtonDisabled: false
      ),
      reducer: counterViewReducer
    )
  )
)
