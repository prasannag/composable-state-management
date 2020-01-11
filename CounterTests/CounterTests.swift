//
//  CounterTests.swift
//  CounterTests
//
//  Created by Prasanna Gopalakrishnan on 28/12/19.
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {
  
  override class func setUp() {
    super.setUp()
    Current = .mock
  }

  func testIncrButtonTapped() {
    var state = CounterViewState(count: 2)
    
    var expected = state
    let effects = counterViewReducer(&state, .counter(.incrTapped))
    
    expected.count = 3
    XCTAssertEqual(state, expected)
    XCTAssert(effects.isEmpty)
  }
  
  func testDecrButtonTapped() {
    var state = CounterViewState(count: 2)
    
    var expected = state
    let effects = counterViewReducer(&state, .counter(.decrTapped))
    
    expected.count = 1
    XCTAssertEqual(state, expected)
    XCTAssert(effects.isEmpty)
  }
  
  func testNthPrimeButtonHappyFlow() {
    Current.nthPrime = { _ in .sync { 17 }}
    var state = CounterViewState(
      alertNthPrime: nil,
      isNthPrimeButtonDisabled: false
    )
    var expected = state
    var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
    
    expected.isNthPrimeButtonDisabled = true
    
    XCTAssertEqual(state, expected)
    XCTAssertEqual(effects.count, 1)
    
    let receivedCompletion = self.expectation(description: "receivedCompletion")
    var nextAction: CounterViewAction!
    effects[0].sink(
      receiveCompletion: { _ in
        receivedCompletion.fulfill()
    }, receiveValue: { action in
      XCTAssertEqual(action, .counter(.nthPrimeResponse(17)))
      nextAction = action
    }
    )
    self.wait(for: [receivedCompletion], timeout: 0.01)
    
    effects = counterViewReducer(&state, nextAction)
    expected.alertNthPrime = PrimeAlert(prime: 17)
    expected.isNthPrimeButtonDisabled = false
    XCTAssertEqual(state, expected)
    XCTAssert(effects.isEmpty)
    
    effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))
    expected.alertNthPrime = nil
    XCTAssertEqual(state, expected)
    XCTAssert(effects.isEmpty)
  }
  
  func testNthPrimeButtonUnhappyFlow() {
    Current.nthPrime = { _ in .sync { nil } }
    var state = CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
    
    var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: true
    ))
    XCTAssertEqual(effects.count, 1)
    
    var nextAction: CounterViewAction!
    let receivedCompletion = self.expectation(description: "receivedCompletion")
    effects[0].sink(
      receiveCompletion: { _ in
        receivedCompletion.fulfill()
    }, receiveValue: { action in
      XCTAssertEqual(action, .counter(.nthPrimeResponse(nil)))
      nextAction = action
    })
    self.wait(for: [receivedCompletion], timeout: 0.01)
    
    effects = counterViewReducer(&state, nextAction)
    
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
    
  }
  
  func testPrimeModal() {
    var state = CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
    
    var effects = counterViewReducer(&state, .primeModal(.saveFavoritePrimeTapped))
    
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5, 2],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
    
    effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))
    
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
  }

}
