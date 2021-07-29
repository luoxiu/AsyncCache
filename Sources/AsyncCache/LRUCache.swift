import Dispatch

public struct LRUCache<Key, Value> where Key: Hashable {
    
    // MARK: Config
    
    public var costLimit: UInt64 {
        didSet {
            trimToCostLimit()
        }
    }
    
    public var maxAge: Time.Span {
        didSet {
            trimToMaxAge()
        }
    }
    
    // MARK: Storage
    private var totalCost = 0
    private var dict: [Key: Unmanaged<LinkedList.Node>] = [:]
    private var linkedList = LinkedList()
    
    // MARK: Init
    public init(costLimit: UInt64 = .max, maxAge: Time.Span = .forever) {
        self.costLimit = costLimit
        self.maxAge = maxAge
    }
    
    // MARK: Operations
    public mutating func set(_ value: Value, for key: Key, cost: Int) {
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
    
    public mutating func value(for key: Key) -> Value? {
        guard let node = dict[key] else {
            return nil
        }
        
        linkedList.moveToLast(node)
        
        return node.takeUnretainedValue().value
    }

    public mutating func removeValue(for key: Key) -> Value? {
        guard let node = dict.removeValue(forKey: key) else {
            return nil
        }
        
        totalCost -= node.takeUnretainedValue().cost
        
        linkedList.remove(node)
        
        return node.takeUnretainedValue().value
    }
    
    public mutating func removeAll() {
        totalCost = 0
        
        dict.removeAll()
        linkedList.removeAll()
    }
}

extension LRUCache {
    
    public mutating func trimToCostLimit() {
        while totalCost > costLimit {
            
            if let first = linkedList.removeFirst() {
                
                first._withUnsafeGuaranteedRef {
                    totalCost -= $0.cost
                    dict[$0.key] = nil
                }
            }
        }
    }
    
    public mutating func trimToMaxAge() {
        
        while let first = linkedList.first {
            
            let removed = first._withUnsafeGuaranteedRef { n -> Bool in
                
                guard n.time.time.advanced(by: maxAge.interval) > .now() else {
                    return false
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
    
    public var keys: AnyCollection<Key> {
        .init(dict.keys)
    }
    
    public func contains(_ key: Key) -> Bool {
        dict.keys.contains(key)
    }
}
