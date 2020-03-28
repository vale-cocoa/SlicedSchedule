//
//  SlicedSchedule
//  SlicedSchedule.swift
//
//  Created by Valeriano Della Longa on 25/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

public struct SlicedSchedule {
    
    /// Error thrown by this type
    public enum Error: Swift.Error {
        
        /// Thrown during initialization when given `elements` parameter contains one or
        ///  more elements invalid for initialization.
        /// - See also: `init(_:)`
        case oneOrMoreInvalidElements
    }
    
    let elements: Array<DateInterval>
    
    /// Returns a new instance contanining no elements, hence empty.
    public init() {
        self.elements = []
    }
    
    /// Returns a new instance containing the elements of the given `Collection`.
    ///
    /// Given collection must not contain elements starting or ending on the same date; also
    /// every element must not overlap on other elements timespan in terms of their start date.
    ///  That is given collection will be sorted in ascending order by its elements' start date value,
    ///  then every element's end date is checked against its following element's start date and
    ///   shouldn't exceeds it otherwise an error will be thrown.
    /// - parameter _: A `Collection` of `DateInterval` elements which consists of
    ///  the schedule elements to use.
    /// - Returns: A new instance contanining the given elements.
    /// - Throws: `Error.oneOrMoreInvalidElements` in case one or more elements in given collection have equal start or end dates, or ovelap another element.
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
            else { throw Error.oneOrMoreInvalidElements }
        
        var overlapping = [DateInterval]()
        for i in 0..<filteredAndSorted.count where i > 0 {
            if filteredAndSorted[i].start < filteredAndSorted[i - 1].end
            {
                overlapping.append(filteredAndSorted[i - 1])
            }
        }
        
        guard
            overlapping.isEmpty
            else { throw Error.oneOrMoreInvalidElements }
        
        self.elements = filteredAndSorted
    }
    
}
