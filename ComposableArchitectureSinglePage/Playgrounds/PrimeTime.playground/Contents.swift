import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit
import PlaygroundSupport

let anIntInTwoSeconds = Effect<Int> { callback in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    callback(42)
  }
}

anIntInTwoSeconds.run { int in print(int) }
anIntInTwoSeconds.map { $0 * $0 }.run { int in print(int) }

import Combine




