import Dispatch

private func clampedMultiply(_ x: UInt64, _ y: UInt64) -> UInt64 {
    let (partialValue, overflow) = x.multipliedReportingOverflow(by: y)

    if overflow {
        return UInt64.max
    }

    return partialValue
}

extension AsyncCache {
    
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

extension AsyncCache.Time {
    
    public struct Span {
        
        let interval: DispatchTimeInterval
        
        init(_ interval: DispatchTimeInterval) {
            self.interval = interval
        }
        
        public static var forever: AsyncCache.Time.Span {
            .init(.never)
        }
    }
}

extension AsyncCache.Time.Span {

    public static func nanoseconds(_ ns: Int) -> AsyncCache.Time.Span {
        .init(.nanoseconds(ns))
    }

    public static func microseconds(_ us: Int) -> AsyncCache.Time.Span {
        .init(.microseconds(us))
    }

    public static func milliseconds(_ ms: Int) -> AsyncCache.Time.Span {
        .init(.milliseconds(ms))
    }

    public static func seconds(_ s: Int) -> AsyncCache.Time.Span {
        .init(.seconds(s))
    }
    
    public static func minutes(_ m: Int) -> AsyncCache.Time.Span {
        .init(.seconds(m * 60))
    }
    
    public static func hours(_ h: Int) -> AsyncCache.Time.Span {
        .init(.seconds(h * 60 * 60))
    }
    
    public static func days(_ d: Int) -> AsyncCache.Time.Span {
        .init(.seconds(d * 60 * 60 * 24))
    }
    
    public static func weeks(_ w: Int) -> AsyncCache.Time.Span {
        .init(.seconds(w * 60 * 60 * 24 * 7))
    }
}
