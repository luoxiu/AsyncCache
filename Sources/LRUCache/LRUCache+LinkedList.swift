extension LRUCache {
    
    @usableFromInline
    final class LinkedList {
    
        @usableFromInline
        var first: Unmanaged<Node>?
        @usableFromInline
        var last: Unmanaged<Node>?

        @inlinable
        init() {
        }
        
        @inlinable
        @inline(__always)
        func append(_ node: Unmanaged<Node>) {
            if let last = last {
                last._withUnsafeGuaranteedRef {
                    $0.next = node
                }
                
                node._withUnsafeGuaranteedRef {
                    $0.previous = last
                }
                
                self.last = node
            } else {
                first = node
                last = node
            }
        }
        
        @inlinable
        @inline(__always)
        func moveToLast(_ node: Unmanaged<Node>) {
            let firstPoint = first!.toOpaque()
            let lastPoint = last!.toOpaque()
            
            let nodePoint = node.toOpaque()
            
            if firstPoint == lastPoint {
                return
            }
            
            node._withUnsafeGuaranteedRef { n in
                if firstPoint == nodePoint {
                    first = n.next
                }
                if lastPoint != nodePoint {
                    last!._withUnsafeGuaranteedRef {
                        $0.next = node
                        n.previous = last
                    }
                    last = node
                }
                
                if let previous = n.previous {
                    previous._withUnsafeGuaranteedRef {
                        $0.next = n.next
                    }
                }
                if let next = n.next {
                    next._withUnsafeGuaranteedRef {
                        $0.previous = n.previous
                    }
                }
            }
        }
        
        /// Assume the first exists.
        @inlinable
        @inline(__always)
        func remove(_ node: Unmanaged<Node>) {
            let firstPoint = first!.toOpaque()
            let lastPoint = last!.toOpaque()
            
            let nodePoint = node.toOpaque()
            
            if firstPoint == lastPoint {
                first = nil
                last = nil
                return
            }
            
            node._withUnsafeGuaranteedRef { n in
                if firstPoint == nodePoint {
                    first = n.next
                }
                if lastPoint == nodePoint {
                    last = n.previous
                }
                
                if let previous = n.previous {
                    previous._withUnsafeGuaranteedRef {
                        $0.next = n.next
                    }
                }
                if let next = n.next {
                    next._withUnsafeGuaranteedRef {
                        $0.previous = n.previous
                    }
                }
            }
        }
        
        /// Assume the first exists.
        @inlinable
        @inline(__always)
        @discardableResult
        func removeFirst() -> Unmanaged<Node> {
            if first!.toOpaque() == last!.toOpaque() {
                defer {
                    first = nil
                    last = nil
                }
                return first!
            }
            
            defer {
                first!._withUnsafeGuaranteedRef {
                    $0.next!._withUnsafeGuaranteedRef {
                        $0.previous = nil
                    }
                    first = $0.next
                }
            }
            
            return first!
        }
        
        @inlinable
        @inline(__always)
        func removeAll() {
            first = nil
            last = nil
        }
    }
}


extension LRUCache.LinkedList {
    
    @usableFromInline
    final class Node {
        
        @usableFromInline
        var previous: Unmanaged<Node>?
        @usableFromInline
        var next: Unmanaged<Node>?
        
        @usableFromInline
        var key: Key
        @usableFromInline
        var value: Value
        
        @usableFromInline
        var cost: Int
        
        @inlinable
        init(key: Key, value: Value, cost: Int) {
            self.key = key
            self.value = value
            
            self.cost = cost
        }
    }
}

