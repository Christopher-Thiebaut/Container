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
