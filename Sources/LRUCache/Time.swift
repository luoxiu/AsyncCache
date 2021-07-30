import Foundation
import QuartzCore

public struct Time {

    /// in nanoseconds
    let moment: UInt64
    
    init(_ moment: UInt64) {
        self.moment = moment
    }
    
    static let timebase_info: mach_timebase_info = {
        var info = mach_timebase_info()
        mach_timebase_info(&info)
        if info.numer == 0 { info.numer = 1 }
        if info.denom == 0 { info.denom = 1 }
        return info
    }()
    
    public static var now: Time {
        let moment = mach_absolute_time() * UInt64(timebase_info.numer) / UInt64(timebase_info.denom)
        return .init(moment)
    }
}

extension Time: Comparable {
    
    public static func < (a: Time, b: Time) -> Bool {
        a.moment < b.moment
    }
    
    public static func == (a: Time, b: Time) -> Bool {
        a.moment == b.moment
    }
}

extension Time {
    
    public struct Span {
        /// in nanoseconds
        let interval: UInt64
        
        init(_ interval: UInt64) {
            self.interval = interval
        }
        
        public static var forever: Time.Span {
            .init(.max)
        }
    }
}

extension Time {
    
    public static func + (time: Time, span: Time.Span) -> Time {
        .init(time.moment + span.interval)
    }
}

extension Time.Span {

    public static func nanoseconds(_ ns: Int) -> Time.Span {
        .init(UInt64(ns))
    }

    public static func microseconds(_ us: Int) -> Time.Span {
        .nanoseconds(us * 1000)
    }

    public static func milliseconds(_ ms: Int) -> Time.Span {
        .nanoseconds(ms * 1000 * 1000)
    }

    public static func seconds(_ s: Int) -> Time.Span {
        .nanoseconds(s * 1000 * 1000 * 1000)
    }
    
    public static func minutes(_ m: Int) -> Time.Span {
        .nanoseconds(m * 1000 * 1000 * 1000 * 60)
    }
    
    public static func hours(_ h: Int) -> Time.Span {
        .nanoseconds(h * 1000 * 1000 * 1000 * 60 * 60)
    }
    
    public static func days(_ d: Int) -> Time.Span {
        .nanoseconds(d * 1000 * 1000 * 1000 * 60 * 60 * 24)
    }
    
    public static func weeks(_ w: Int) -> Time.Span {
        .nanoseconds(w * 1000 * 1000 * 1000 * 60 * 60 * 24 * 7)
    }
}
