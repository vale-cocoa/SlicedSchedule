//
//  SlicedSchedule
//  SlicedSchedule.swift
//
//  Created by Valeriano Della Longa on 25/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

public struct SlicedSchedule {
    public enum Error: Swift.Error {
        case oneOrMoreInvalidElement
    }
    
    let elements: Array<DateInterval>
    
    public init() {
        self.elements = []
    }
    
    public init<C: Collection>(_ elements: C) throws
        where C.Iterator.Element == DateInterval
    {
        var uniqueStartDates: Set<Date> = []
        var uniqueEndDates: Set<Date> = []
        let filteredAndSorted: [DateInterval] = elements
            .filter { uniqueStartDates.insert($0.start).inserted == true && uniqueEndDates.insert($0.end).inserted == true }
            .sorted { $0.start < $1.start }
        
        guard
            uniqueStartDates.count == uniqueEndDates.count,
            uniqueStartDates.count == elements.count
            else { throw Error.oneOrMoreInvalidElement }
        
        var overlapping = [DateInterval]()
        for i in 0..<filteredAndSorted.count where i > 0 {
            if filteredAndSorted[i].start < filteredAndSorted[i - 1].end
            {
                overlapping.append(filteredAndSorted[i - 1])
            }
        }
        
        guard
            overlapping.isEmpty
            else { throw Error.oneOrMoreInvalidElement }
        
        self.elements = filteredAndSorted
    }
    
}
