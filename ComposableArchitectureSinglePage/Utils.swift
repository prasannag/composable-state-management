//
//  Utils.swift
//  ComposableArchitectureSinglePage
//
//  Created by Prasanna Gopalakrishnan on 26/11/19.
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

import Foundation

public func compose<A, B, C>(
  _ f: @escaping (B) -> C,
  _ g: @escaping (A) -> B
  )
  -> (A) -> C {

    return { (a: A) -> C in
      f(g(a))
    }
}

public func with<A, B>(_ a: A, _ f: (A) throws -> B) rethrows -> B {
  return try f(a)
}

