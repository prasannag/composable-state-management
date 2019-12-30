//
//  Copyright © 2019 Prasanna Gopalakrishnan. All rights reserved.
//

import SwiftUI
import Combine

public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action>
  @Published public private(set) var value: Value
  private var cancellable: Cancellable?
  
  public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
    self.reducer = reducer
    self.value = initialValue
  }
  
  public func send(_ action: Action) {
    let effects = self.reducer(&self.value, action)
    effects.forEach { effect in
      effect(self.send)
    }
  }
  
  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return []
      }
    )
    localStore.cancellable = self.$value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...)
  -> Reducer<Value, Action> {
    return { value, action in
      let effects = reducers.flatMap { $0(&value, action) }
      return effects
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>)
  -> Reducer<GlobalValue, GlobalAction> {

  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)
    return localEffects.map { localEffect in
      { callback in
        localEffect { localAction in
          var globalAction = globalAction
          globalAction[keyPath: action] = localAction
          callback(globalAction)
        }
      }
    }
  }
}

public func logging<Value, Action> (
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [{ _ in
      print("Action: \(action)")
      print("Value: ")
      dump(newValue)
      print("---")
    }] + effects
  }
}
