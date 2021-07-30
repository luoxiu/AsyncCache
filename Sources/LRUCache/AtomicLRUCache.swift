import Foundation

public final class AtomicLRUCache<Key, Value> where Key: Hashable {
    
    private var unfair_lock = os_unfair_lock_s()
    
    private var cache: LRUCache<Key, Value>
    
    public init(
        minimumCapacity: Int = 2 ^ 5,
        costLimit: Int = .max,
        maxAge: Time.Span = .forever
    ) {
        cache = .init(minimumCapacity: minimumCapacity,
                      costLimit: costLimit,
                      maxAge: maxAge)
    }
    
    // MARK: Config
    
    public var costLimit: Int {
        get {
            os_unfair_lock_lock(&unfair_lock)
            defer { os_unfair_lock_unlock(&unfair_lock) }
            
            return cache.costLimit
        }
        set {
            os_unfair_lock_lock(&unfair_lock)
            defer { os_unfair_lock_unlock(&unfair_lock) }
            
            cache.costLimit = newValue
        }
    }
    
    public var maxAge: Time.Span {
        get {
            os_unfair_lock_lock(&unfair_lock)
            defer { os_unfair_lock_unlock(&unfair_lock) }
            
            return cache.maxAge
        }
        set {
            os_unfair_lock_lock(&unfair_lock)
            defer { os_unfair_lock_unlock(&unfair_lock) }
            
            cache.maxAge = newValue
        }
    }
    
    public var totalCost: Int {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.totalCost
    }
    
    public func setValue(_ value: Value, forKey key: Key, cost: Int = 1) {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.setValue(value, forKey: key, cost: cost)
    }
    
    public func value(forKey key: Key) -> Value? {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.value(forKey: key)
    }
    
    public func removeValue(forKey key: Key) -> Value? {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.removeValue(forKey: key)
    }
    
    public func removeAll(keepingCapacity: Bool = false) {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public func trimToCostLimit() {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.trimToCostLimit()
    }
    
    public func trimToMaxAge() {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.trimToMaxAge()
    }
    
    public func contains(_ key: Key) -> Bool {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.contains(key)
    }
    
    public var count: Int {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.count
    }
}
