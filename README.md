# Container

Container is a runtime dependency injection framework written in Swift, written with developer ergonomics in mind.

The major goals of this project are enabling greater developer ergonomics, making the easy choice the right choice, and ensuring that code that relies on Container is fully testable.

As such, there's no singleton or shared instance of `Container` that's accessible throughout your app.  Just use the `@Containerized` property wrapper to say your object is expecting to receive its dependencies from some `Container`, and then you free your objects from having to worry about transitive dependencies or passing dependencies through 5 layers of initializers.  

Then, just initialize the root of your object graph and pass it to `container.fill` to automagically associate the `Container` with your object and all of its descendants.  At the same time, you can easily test your object in isolation because each test can have its own instance of `Container` that is used to initialize the subject under test.
