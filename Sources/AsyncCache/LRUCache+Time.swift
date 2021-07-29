import Dispatch

private func clampedMultiply(_ x: UInt64, _ y: UInt64) -> UInt64 {
    let (partialValue, overflow) = x.multipliedReportingOverflow(by: y)

    if overflow {
        return UInt64.max
    }

    return partialValue
}

extension LRUCache {
    
    public struct Time {

        let time: DispatchTime
        
        init(_ time: DispatchTime) {
            self.time = time
        }

        public static var now: Time {
            .init(DispatchTime.now())
        }
    }
}

extension LRUCache.Time {
    
    public struct Span {
        
        let interval: DispatchTimeInterval
        
        init(_ interval: DispatchTimeInterval) {
            self.interval = interval
        }
        
        public static var forever: LRUCache.Time.Span {
            .init(.never)
        }
    }
}

extension LRUCache.Time.Span {

    public static func nanoseconds(_ ns: Int) -> LRUCache.Time.Span {
        .init(.nanoseconds(ns))
    }

    public static func microseconds(_ us: Int) -> LRUCache.Time.Span {
        .init(.microseconds(us))
    }

    public static func milliseconds(_ ms: Int) -> LRUCache.Time.Span {
        .init(.milliseconds(ms))
    }

    public static func seconds(_ s: Int) -> LRUCache.Time.Span {
        .init(.seconds(s))
    }
    
    public static func minutes(_ m: Int) -> LRUCache.Time.Span {
        .init(.seconds(m * 60))
    }
    
    public static func hours(_ h: Int) -> LRUCache.Time.Span {
        .init(.seconds(h * 60 * 60))
    }
    
    public static func days(_ d: Int) -> LRUCache.Time.Span {
        .init(.seconds(d * 60 * 60 * 24))
    }
    
    public static func weeks(_ w: Int) -> LRUCache.Time.Span {
        .init(.seconds(w * 60 * 60 * 24 * 7))
    }
}
