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
        
        public init(_ time: DispatchTime) {
            self.time = time
        }

        public static var now: Time {
            .init(DispatchTime.now())
        }
    }
}

extension AsyncCache.Time {
    
    public struct Span {
        let nanoseconds: UInt64
    }
}

extension AsyncCache.Time.Span {

    public static func nanoseconds(_ ns: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: UInt64(ns))
    }

    public static func microseconds(_ us: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(us), 1000))
    }

    public static func milliseconds(_ ms: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(ms), 1000 * 1000))
    }

    public static func seconds(_ s: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(s), 1000 * 1000 * 1000))
    }
    
    public static func minutes(_ m: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(m), 1000 * 1000 * 1000 * 60))
    }
    
    public static func hours(_ h: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(h), 1000 * 1000 * 1000 * 60 * 60))
    }
    
    public static func days(_ d: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(d), 1000 * 1000 * 1000 * 60 * 60 * 24))
    }
    
    public static func weeks(_ w: Int) -> AsyncCache.Time.Span {
        .init(nanoseconds: clampedMultiply(UInt64(w), 1000 * 1000 * 1000 * 60 * 60 * 24 * 7))
    }
}

extension AsyncCache.Time.Span {
    public static var forever: AsyncCache.Time.Span {
        .init(nanoseconds: .max)
    }
}
