import XCTest
@testable import LRUCache

private class Obj { }

final class AsyncCacheTests: XCTestCase {
    
    private let count = 10
    
    private lazy var data = (0..<count).map {
        (
            $0,
            Int.random(in: Int.min...Int.max)
        )
    }
    
    override func setUp() async throws {
        
    }
    
    func testSetGet() {
        var cache = LRUCache<Int, Int>()
        
        data.forEach {
            cache.setValue($0.1, forKey: $0.0)
        }
        
        XCTAssertEqual(cache.count, count)
        
        XCTAssertEqual(cache.orderedKeys, data.map { $0.0 })
        
        let values = data.compactMap {
            cache.value(forKey: $0.0)
        }
        
        XCTAssertEqual(data.map { $0.1 }, values)
    }

    func testCostLimit() {
        var cache = LRUCache<Int, Int>()
        
        cache.costLimit = 5
        
        data.forEach {
            cache.setValue($0.1, forKey: $0.0)
        }
        
        XCTAssertEqual(cache.count, 5)
        
        XCTAssertEqual(cache.orderedKeys, data.suffix(5).map { $0.0 })
        
        cache.costLimit = 1
        
        XCTAssertEqual(cache.count, 1)
        
        XCTAssertEqual(cache.orderedKeys, data.suffix(1).map { $0.0 })
    }
    
    func testMaxAge() {
        var cache = LRUCache<Int, Int>()
        
        data.forEach {
            cache.setValue($0.1, forKey: $0.0)
        }
        
        data.forEach { _ in
        }
    }
    
    func testCopy() {
        var cache = LRUCache<Int, Int>()
        cache.setValue(1, forKey: 1)
        cache.setValue(2, forKey: 2)
        
        var cache2 = cache
        let value = cache2.value(forKey: 1)
        XCTAssertEqual(value, 1)
        
        cache2.setValue(2, forKey: 1)
        XCTAssertEqual(cache.value(forKey: 1), 1)
        XCTAssertEqual(cache2.value(forKey: 1), 2)
        
        cache.costLimit = 1
        XCTAssertEqual(cache.count, 1)
        XCTAssertEqual(cache2.count, 2)
    }
}
