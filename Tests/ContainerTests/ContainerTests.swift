import XCTest
import Container

final class ContainerTests: XCTestCase {
    var subject: Container!
    
    override func setUpWithError() throws {
        subject = Container()
    }
    func testResolve() throws {
        subject.bind { 15 }
        XCTAssertEqual(15, try subject.resolve())
    }
    
    func testFill() {
        subject.bind { "Hello, World" }
        
        let greeter = Greeter()
        subject.fill(greeter)
        
        XCTAssertEqual(greeter.greet(), "Hello, World")
    }
    
    func testFillRecursive() {
        class Store {
            var greeter = Greeter()
        }
        
        subject.bind { "Hello, Containers!" }
        
        let store = Store()
        subject.fill(store)
        XCTAssertEqual(store.greeter.greet(), "Hello, Containers!")
    }
    
    func testRecursiveDeathSpiral() throws {
        //Note: This is an intentional reference cycle to test the container's handling of reference cycles. (Some reactive libraries have intentional reference cycles)
        class HostileRecursiveExample {
            let greeting = "Hello, World"
            var child: ParentReferentialThing?
            
            class ParentReferentialThing {
                var parent: HostileRecursiveExample
                
                init(parent: HostileRecursiveExample) {
                    self.parent = parent
                }
            }
            
            init() {
                child = ParentReferentialThing(parent: self)
            }
        }
        
        class Greeter {
            @Containerized var message: HostileRecursiveExample
        }
        
        subject.bind { HostileRecursiveExample() }
        subject.bind { Greeter() }
        
        let greeter: Greeter = try subject.resolve()
        XCTAssertEqual(greeter.message.greeting, "Hello, World")
    }
    

    static var allTests = [
        ("testResolve", testResolve),
        ("testBuild", testFill)
    ]
}

class Greeter {
    @Containerized var greeting: String
    
    func greet() -> String {
        return greeting
    }
}
