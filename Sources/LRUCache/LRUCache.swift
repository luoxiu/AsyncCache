import Dispatch
import CoreFoundation

public struct LRUCache<Key, Value> where Key: Hashable {
    
    // MARK: Config

    public var costLimit: Int {
        didSet {
            precondition(costLimit >= 0)
            trimToCostLimit()
        }
    }
    
    // MARK: Storage
    @usableFromInline
    var _totalCost = 0
    
    @usableFromInline
    var _dict: [Key: Unmanaged<LinkedList.Node>]
    
    @usableFromInline
    var _list: LinkedList
    
    // MARK: Init
    @inlinable
    public init(
        minimumCapacity: Int = 2 ^ 5,
        costLimit: Int = .max,
        maxAge: Time.Span = .forever
    ) {
        precondition(costLimit >= 0)
        
        self.costLimit = costLimit
        
        self._dict = .init(minimumCapacity: minimumCapacity)
        self._list = LinkedList()
    }
    
    // MARK: Operations
    
    @inlinable
    public mutating func setValue(_ value: __owned Value, forKey key: Key, cost: Int = 1) {
        copyIfNotUniquelyRef()
        
        if let node = _dict[key] {
            
            node._withUnsafeGuaranteedRef { n in
                _totalCost -= n.cost
                _totalCost += cost

                n.value = value
                
                _list.moveToLast(node)
            }
        } else {
            _totalCost += cost
            
            let node = LinkedList.Node(key: key, value: value, cost: cost)
            let unmanaged = Unmanaged<LinkedList.Node>.passRetained(node)
            
            _dict[key] = unmanaged
            
            _list.append(unmanaged)
        }
        
        trimToCostLimit()
    }
    
    @inlinable
    public mutating func value(forKey key: Key) -> Value? {
        copyIfNotUniquelyRef()
        
        guard let node = _dict[key] else {
            return nil
        }
        
        _list.moveToLast(node)
        
        return node.takeUnretainedValue().value
    }

    @inlinable
    public mutating func removeValue(forKey key: Key) -> Value? {
        copyIfNotUniquelyRef()
        
        guard let node = _dict.removeValue(forKey: key) else {
            return nil
        }
        
        _totalCost -= node.takeUnretainedValue().cost

        _list.remove(node)
        
        return node.takeUnretainedValue().value
    }
    
    @inlinable
    public mutating func removeAll(keepingCapacity: Bool = false) {
        copyIfNotUniquelyRef()
        
        _totalCost = 0
        
        _dict.removeAll(keepingCapacity: keepingCapacity)
        _list.removeAll()
    }
}

extension LRUCache {
    
    @inlinable
    public mutating func trimToCostLimit() {
        var copied = false
        
        while _totalCost > costLimit && count > 0 {
            
            if !copied {
                copied = true
                copyIfNotUniquelyRef()
            }
            
            let first = _list.removeFirst()
            
            first._withUnsafeGuaranteedRef {
                _totalCost -= $0.cost
                _dict[$0.key] = nil
            }
        }
    }
}

extension LRUCache {
    
    @inlinable
    public func contains(_ key: Key) -> Bool {
        _dict.keys.contains(key)
    }
    
    @inlinable
    public var count: Int {
        _dict.count
    }
    
    @inlinable
    public var totalCost: Int {
        _totalCost
    }
    
    /// Ordered by write time.
    @inlinable
    public var orderedKeys: [Key] {
        var keys: [Key] = []
        
        var node = _list.first
        
        while let n = node {
            n._withUnsafeGuaranteedRef {
                keys.append($0.key)
                node = $0.next
            }
        }
        
        return keys
    }

    @inlinable
    public func peekValue(forKey key: Key) -> Value? {
        _dict[key]?._withUnsafeGuaranteedRef {
            $0.value
        }
    }
}

// MARK: Copy
extension LRUCache {
    
    @inlinable
    @inline(__always)
    mutating func copyIfNotUniquelyRef() {
        if !isKnownUniquelyReferenced(&_list) {
            self = copy()
        }
    }
    
    @inlinable
    @inline(__always)
    func copy() -> LRUCache {
        
        var cache = LRUCache(
            minimumCapacity: _dict.capacity,
            costLimit: costLimit
        )
        
        var node = _list.first
        
        while let n = node {

            n._withUnsafeGuaranteedRef { ref in
                
                cache.setValue(ref.value, forKey: ref.key, cost: ref.cost)
                node = ref.next
            }
        }
        
        return cache
    }
}
