//
//  Containerized.swift
//
//
//  Created by Christopher Thiebaut on 7/23/20.
//

/// `Container` has three primary functions. `bind` stores app dependencies in the container.  `resolve` resolves a single dependency which has been stored in the container.  `resolve` will result in a `fatalError` if the dependency has not been injected with `bind`.  `fill` will resolve properties marked as `@Containerized` on an already-instantiated object
///
/// `Container` is used to store your app's dependencies and resolve them when needed.  It can be used directly by using `bind` to store debendencies and `resolve` to retrieve them.  However, this is not the recommended usage since it either requires keeping an instance of `Container` at a global scope or injecting it down through your object graph.
///
/// Instead, you should use `Container` in conjuncton with its accompanying property wrapper `Containerized`.  Throughout your app, simply mark your object's dependencies as `@Containerized ` rather than injecting them through your initializers and forcing objects to be
/// aware of recursive dependencies.  At that point, you can simply call `container.fill(yourObject)` and all of its dependencies (recursively) which are marked `@Containerized` will be resolved from `container` when needed.  This way, you do not need to give downstram objects the freedom to get things from the container ad hoc
///
///
public class Container {
    public enum ContainerError: Error {
        case noDependencyBound(String)
    }
    private var dependencies = [String: () -> Any]()

    public init() {}
    
    /// Use `bind` to store a closure to produce an object of the type `T`.  If you want to produce a new object for each time the dependency
    /// is requested, create a new object in your closure.  If you want to use a singleton throughout your application, capture an existing object and simply return it (note, however, that this object will remain in memory for the lifetime of your application).
    ///
    /// If the object's dependencies are marked `@Containerized`, they will be resolved lazily from the same container after they are `resolve`d.
    /// - Parameter dependency: A closure which returns the object type you would like to use to satisfy dependencies in your application.  If you want to bind a concrete class to a protocol, that can be accomplished by casting it, such as `container.bind { URLSession.shared as URLProtocol }`
    public func bind<T>(_ dependency: @escaping () -> T) {
        dependencies[String(describing: T.self)] = dependency
    }
    
    
    /// Use `resolve` to get an instance of an object the has previously been associated to a type with `bind`.
    /// If `T` has any `@Containerized` properties, they will be resolved lazily from the same container.
    /// - Throws: Throws a `ContainerError` if the dependency has not been previously associated with `T` using `bind`
    /// - Returns: An instance of `T`
    public func resolve<T>() throws -> T {
        guard let object = dependencies[String(describing: T.self)]?() as? T else {
            throw ContainerError.noDependencyBound("No bound dependency for \(T.self)")
        }
        fill(object)
        return object
    }
    
    
    /// Call `fill` to associate an instance of `Container` with an already created object and its descandants in the object tree.  Any properties of the object that are marked as `@Containerized` will be resolved from this container
    ///
    /// NOTE: Properties marked as `lazy` and their descendants will not be associated with the container.  To get around this issue, keep your non-containerized properties lightweight and allow them to be constructed eagerly.  `@Containerized` properties will be initialized lazily.
    /// - Parameter object: The root of the object tree to be associated with the container
    public func fill<T>(_ object: T) {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            guard let containing = child.value as? ContainerHolder else {
                fill(child.value)
                continue
            }
            containing.container.value = self
        }
    }
}

protocol ContainerHolder {
    var container: Indirect<Container> { get }
}

class Indirect<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}
