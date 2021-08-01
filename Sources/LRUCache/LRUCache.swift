import Dispatch

public struct LRUCache<Key, Value> where Key: Hashable {
    
    // MARK: Config

    public var costLimit: Int {
        didSet {
            precondition(costLimit >= 0)
            trimToCostLimit()
        }
    }
    
    public var maxAge: Time.Span {
        didSet {
            trimToMaxAge()
        }
    }
    
    // MARK: Storage
    public private(set) var totalCost = 0
    
    private var dict: [Key: Unmanaged<LinkedList.Node>]
    private var linkedList: LinkedList
    
    // MARK: Init
    public init(
        minimumCapacity: Int = 2 ^ 5,
        costLimit: Int = .max,
        maxAge: Time.Span = .forever
    ) {
        precondition(costLimit >= 0)
        
        self.costLimit = costLimit
        self.maxAge = maxAge
        
        self.dict = .init(minimumCapacity: minimumCapacity)
        self.linkedList = LinkedList()
    }
    
    // MARK: Operations
    
    public mutating func setValue(_ value: Value, forKey key: Key, cost: Int = 1) {
        copyIfNotUniquelyRef()
        
        if let node = dict[key] {
            
            node._withUnsafeGuaranteedRef { n in
                totalCost -= n.cost
                totalCost += cost
                
                n.time = Time.now
                
                n.value = value
                
                linkedList.moveToLast(node)
            }
        } else {
            totalCost += cost
            
            let node = LinkedList.Node(key: key, value: value, cost: cost, time: .now)
            let unmanaged = Unmanaged<LinkedList.Node>.passRetained(node)
            
            dict[key] = unmanaged
            
            linkedList.append(unmanaged)
        }
        
        trimToCostLimit()
    }
    
    public mutating func value(forKey key: Key) -> Value? {
        copyIfNotUniquelyRef()
        
        guard let node = dict[key] else {
            return nil
        }
        
        linkedList.moveToLast(node)
        
        return node.takeUnretainedValue().value
    }

    public mutating func removeValue(forKey key: Key) -> Value? {
        copyIfNotUniquelyRef()
        
        guard let node = dict.removeValue(forKey: key) else {
            return nil
        }
        
        totalCost -= node.takeUnretainedValue().cost

        linkedList.remove(node)
        
        return node.takeUnretainedValue().value
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        copyIfNotUniquelyRef()
        
        totalCost = 0
        
        dict.removeAll(keepingCapacity: keepingCapacity)
        linkedList.removeAll()
    }
}

extension LRUCache {
    
    public mutating func trimToCostLimit() {
        var copied = false
        
        while totalCost > costLimit && count > 0 {
            
            if !copied {
                copied = true
                copyIfNotUniquelyRef()
            }
            
            let first = linkedList.removeFirst()
            
            first._withUnsafeGuaranteedRef {
                totalCost -= $0.cost
                dict[$0.key] = nil
            }
        }
    }
    
    public mutating func trimToMaxAge() {
        var copied = false
        
        while let first = linkedList.first {
            
            let removed = first._withUnsafeGuaranteedRef { n -> Bool in
                
                guard n.time + maxAge > .now else {
                    return false
                }
                
                if !copied {
                    copied = true
                    copyIfNotUniquelyRef()
                }
                
                dict[n.key] = nil
                linkedList.removeFirst()
                
                return true
            }
            
            guard removed else { break }
        }
    }
}

extension LRUCache {
    
    public func contains(_ key: Key) -> Bool {
        dict.keys.contains(key)
    }
    
    public var count: Int {
        dict.count
    }
}

// MARK: Copy
extension LRUCache {
    
    private mutating func copyIfNotUniquelyRef() {
        if !isKnownUniquelyReferenced(&linkedList) {
            self = copy()
        }
    }
    
    private func copy() -> LRUCache {
        
        var cache = LRUCache(
            minimumCapacity: dict.capacity,
            costLimit: costLimit,
            maxAge: maxAge
        )
        
        var node = linkedList.first
        
        while let n = node {

            n._withUnsafeGuaranteedRef { ref in
                
                cache.setValue(ref.value, forKey: ref.key, cost: ref.cost)
                
                cache.linkedList.last!._withUnsafeGuaranteedRef {
                    $0.time = ref.time
                }
                
                node = ref.next
            }
        }
        
        return cache
    }
}

// MARK: Debug
extension LRUCache {
    
    /// Ordered by write time.
    var orderedKeys: [Key] {
        var keys: [Key] = []
        
        var node = linkedList.first
        
        while let n = node {
            n._withUnsafeGuaranteedRef {
                keys.append($0.key)
                node = $0.next
            }
        }
        
        return keys
    }
    
    /// Ordered by write time.
    var orderedValues: [Value] {
        var values: [Value] = []
        
        var node = linkedList.first
        
        while let n = node {
            n._withUnsafeGuaranteedRef {
                values.append($0.value)
                node = $0.next
            }
        }
        
        return values
    }
}
