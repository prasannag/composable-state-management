////
////  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
////
//
//import Foundation
//
//extension Effect {
//  public func receive(on queue: DispatchQueue) -> Effect {
//    return Effect { callback in
//      self.run { a in
//        queue.async {
//          callback(a)
//        }
//      }
//    }
//  }
//}
//
//extension Effect where A == (Data?, URLResponse?, Error?) {
//  public func decode<M: Decodable>(as type: M.Type) -> Effect<M?>  {
//    return self.map { data, _, _ in
//      data.flatMap { try? JSONDecoder().decode(M.self, from: $0) }
//    }
//  }
//}
//
//public func dataTask(with request: URL) -> Effect<(Data?, URLResponse?, Error?)> {
//  return Effect { callback in
//    URLSession.shared.dataTask(with: request) { data, response, error in
//      callback((data, response, error))
//    }
//    .resume()
//  }
//}
