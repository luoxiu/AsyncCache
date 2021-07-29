import Dispatch

public actor AsyncCache<Key, Value> where Key: Hashable {
    
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
    public func set(_ value: Value, for key: Key, cost: Int) {
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
    
    public func value(for key: Key) -> Value? {
        guard let node = dict[key] else {
            return nil
        }
        
        linkedList.moveToLast(node)
        
        return node.takeUnretainedValue().value
    }
    
    public func contains(_ key: Key) -> Bool {
        dict.keys.contains(key)
    }
    
    public func removeValue(for key: Key) -> Value? {
        guard let node = dict.removeValue(forKey: key) else {
            return nil
        }
        
        totalCost -= node.takeUnretainedValue().cost
        
        linkedList.remove(node)
        
        return node.takeUnretainedValue().value
    }
    
    public func removeAll() {
        totalCost = 0
        
        dict.removeAll()
        linkedList.removeAll()
    }
    
    public func trimToCostLimit() {
        while totalCost > costLimit {
            
            if let first = linkedList.removeFirst() {
                
                first._withUnsafeGuaranteedRef {
                    totalCost -= $0.cost
                    dict[$0.key] = nil
                }
            }
        }
    }
    
    public func trimToMaxAge() {
        
        while let first = linkedList.first {
            
            let removed = first._withUnsafeGuaranteedRef { n -> Bool in
                
                if n.time.time.advanced(by: maxAge.interval) < .now() {
                    
                    dict[n.key] = nil
                    linkedList.removeFirst()
                    
                    return false
                }
                
                return true
            }
            
            guard removed else { break }
        }
    }
}
