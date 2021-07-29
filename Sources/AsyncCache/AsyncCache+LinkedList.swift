extension AsyncCache {
    
    final class LinkedList {
        
        var first: Unmanaged<Node>?
        var last: Unmanaged<Node>?

        init() {
        }
        
        func append(_ node: Unmanaged<Node>) {
            if let last = last {
                last._withUnsafeGuaranteedRef {
                    $0.previous = node
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
        @discardableResult
        func removeFirst() -> Unmanaged<Node>? {
            if first!.toOpaque() == last!.toOpaque() {
                defer {
                    first = nil
                    last = nil
                }
                return first!
            }
            
            first!._withUnsafeGuaranteedRef {
                $0.next!._withUnsafeGuaranteedRef {
                    $0.previous = nil
                }
                first = $0.next
            }
            
            return nil
        }
        
        func removeAll() {
            first = nil
            last = nil
        }
    }
}


extension AsyncCache.LinkedList {
    
    final class Node {
        var previous: Unmanaged<Node>?
        var next: Unmanaged<Node>?
        
        var key: Key
        var value: Value
        
        var cost: Int
        
        var time: AsyncCache.Time
        
        init(key: Key, value: Value, cost: Int, time: AsyncCache.Time) {
            self.key = key
            self.value = value
            
            self.cost = cost
            
            self.time = time
        }
    }
}

