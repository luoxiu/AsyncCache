import Foundation

public final class AtomicLRUCache<Key, Value> where Key: Hashable {
    
    @usableFromInline
    var unfair_lock = os_unfair_lock_s()
    
    @usableFromInline
    var cache: LRUCache<Key, Value>
    
    @inlinable
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
    @inlinable
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
    
    @inlinable
    public var totalCost: Int {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache._totalCost
    }
    
    @inlinable
    public func setValue(_ value: Value, forKey key: Key, cost: Int = 1) {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.setValue(value, forKey: key, cost: cost)
    }
    
    @inlinable
    public func value(forKey key: Key) -> Value? {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.value(forKey: key)
    }
    
    @inlinable
    public func removeValue(forKey key: Key) -> Value? {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.removeValue(forKey: key)
    }
    
    @inlinable
    public func removeAll(keepingCapacity: Bool = false) {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.removeAll(keepingCapacity: keepingCapacity)
    }
    
    @inlinable
    public func trimToCostLimit() {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        cache.trimToCostLimit()
    }
    
    @inlinable
    public func contains(_ key: Key) -> Bool {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.contains(key)
    }
    
    @inlinable
    public var count: Int {
        os_unfair_lock_lock(&unfair_lock)
        defer { os_unfair_lock_unlock(&unfair_lock) }
        
        return cache.count
    }
}
