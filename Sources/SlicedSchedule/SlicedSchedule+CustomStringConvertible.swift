//
//  SlicedSchedule
//  SlicedSchedule+CustomStringConvertible.swift
//  
//  Created by Valeriano Della Longa on 26/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

extension SlicedSchedule: CustomStringConvertible {
    
    var formatter: DateIntervalFormatter {
        let diFormatter = DateIntervalFormatter()
        var gregCal = Calendar.init(identifier: .gregorian)
        gregCal.locale = Locale(identifier: "en_US_POSIX")
        gregCal.timeZone = TimeZone(secondsFromGMT: 0)!
        diFormatter.calendar = gregCal
        diFormatter.timeZone = gregCal.timeZone
        diFormatter.dateStyle = .long
        
        return diFormatter
    }
    
    public var description: String {
        let dateIntervalsStrings = elements
            .compactMap { formatter.string(from: $0.start, to: $0.end)
        }
        
        return "Schedule elements: \(dateIntervalsStrings)"
    }
}
