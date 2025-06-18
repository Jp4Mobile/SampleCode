//
//  ViewModel.swift
//  TaskManager
//
//  Created by Jp LaFond on 6/13/25.
//  Based on the work of Eduardo Sanches Bocato from: https://bocato.medium.com/improving-mvvm-forms-in-swiftui-14b032065095
//

import Foundation
import SwiftUI

open class StateBindingViewModel<State: Equatable>: ObservableObject {
    /// Defines the state to be represented by the view.
    @Published public private(set) var state: State

    /// Initializes the ViewModel with the first / initial state for the flow.
    /// - Parameter initialState: the initial state of the flow.
    public init(initialState: State) {
        self.state = initialState
    }

    /// Creates a `Binding` for some value from state.
    /// - Parameter keyPath: the keyPath, representing some property of the `State`
    /// - Returns: a `Binding<Value>` of the `State` property represented by the keyPath
    public func binding<Value>(
        _ keyPath: WritableKeyPath<State, Value>
    ) -> Binding<Value> where Value: Equatable {
        .init(
            get: { self.state[keyPath: keyPath] },
            set: { [weak self] newValue in
                guard let self = self else { return }

                guard // Notifies the change and returns if it should be applied.
                    self.stateWillChangeValue(keyPath, newValue: newValue)
                else { return }

                let oldValue = self.state[keyPath: keyPath] // Holds the current value, that will become the `oldValue`.
                guard newValue != oldValue else { return } // Checks if something has really changed.
                self.state[keyPath: keyPath] = newValue // Sets the `newValue` to state.
                self.onStateChange(keyPath) // Notifies the state change.
            }
        )
    }

    /// Updates a property of the `state`.
    /// - Parameters:
    ///   - keyPath: the keyPath, representing some property of the `State`.
    ///   - newValue: the newValue to be set on the `State` property.
    public func update<Value>(
        _ keyPath: WritableKeyPath<State, Value>,
        to newValue: Value
    ) where Value: Equatable {
        self.state[keyPath: keyPath] = newValue
    }

    /// Defines a way to access the value to be changed, before it's change is commited.
    /// - Parameters:
    ///   - keyPath: the keyPath, representing some property of the `State`
    ///   - newValue: the newValue to be set on the `State` property
    /// - Returns: whether the value change/update should be allowed or not
    /// - Note: if not overriden, it will always return `true`to allow everyting to be updated.
    open func stateWillChangeValue<Value>(
        _ keyPath: PartialKeyPath<State>,
        newValue: Value
    ) -> Bool where Value: Equatable {
        return true
    }

    /// Notifies that the value for some `State`property was changed.
    /// It can be used to fire aditional events, state mutations or else.
    /// - Parameter keyPath: the keyPath, representing some property of the `State`
    open func onStateChange(_ keyPath: PartialKeyPath<State>) {}
}
