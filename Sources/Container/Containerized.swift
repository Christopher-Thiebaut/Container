//
//  Containerized.swift
//  
//
//  Created by Christopher Thiebaut on 7/23/20.
//

import Foundation

@propertyWrapper public struct Containerized<T>: ContainerHolder {
    
    var container = Indirect<Container>(Container())
    
    var _storage: T?
    public var wrappedValue: T {
        mutating get {
            let value: T
            do {
                value = try _storage ?? container.value.resolve()
            } catch {
                fatalError("Could not resolve containerized dependency")
            }
            _storage = value
            return value
        }
        set {
            _storage = newValue
        }
    }
    
    public init() {}
}
