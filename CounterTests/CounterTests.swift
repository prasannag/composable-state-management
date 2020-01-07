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

  func testIncrButtonTapped() {
    var state = CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
    
    let effects = counterViewReducer(&state, .counter(.incrTapped))
    
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 3,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
  }
  
  func testDecrButtonTapped() {
    var state = CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
    
    let effects = counterViewReducer(&state, .counter(.decrTapped))
    
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 1,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
  }
  
  func testNthPrimeButtonFlow() {
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
    
    effects = counterViewReducer(&state, .counter(.nthPrimeResponse(3)))
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: PrimeAlert(prime: 3),
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
    
    effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))
    XCTAssertEqual(state, CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    ))
    XCTAssert(effects.isEmpty)
  }

}
