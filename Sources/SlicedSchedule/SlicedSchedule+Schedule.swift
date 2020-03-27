//
//  SlicedSchedule
//  SlicedSchedule+Schedule.swift
//  
//  Created by Valeriano Della Longa on 27/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLGCDHelpers

extension SlicedSchedule: Schedule {
    var lowerBound: Date? { return self.elements.first?.start }
    var upperBound: Date? { return self.elements.last?.end }
    
    public var isEmpty: Bool { return elements.isEmpty }
    
    public func contains(_ date: Date) -> Bool {
        guard
            !isEmpty,
            date >= lowerBound!,
            date <= upperBound!,
            let _ = elements.last(where: { $0.contains(date) })
            else { return false }
        
        return true
    }
    
    public func schedule(matching date: Date, direction: CalendarCalculationMatchingDateDirection) -> Self.Element? {
        guard !isEmpty else { return nil }
        
        switch direction {
        case .on:
            guard
                date >= lowerBound!,
                date <= upperBound!
                else { return nil }
            
            return elements
                .last(where: { $0.contains(date) })
        
        case .firstAfter:
            guard date < elements.last!.start else { return nil }
            
            if date < lowerBound! { return elements.first }
            
            if
                let idxOfOn = elements
                    .firstIndex(where: { $0.contains(date) })
            {
                // There's an element containing the date…
                // …we return next one!
                // This is safe since we've guarded against
                // date greater than or equal last element's start
                return elements[idxOfOn + 1]
            } else {
                // No element contains the date,
                // hence we return the first one whose start is
                // greater than the date!
                return elements
                    .first(where: { $0.start > date })
            }
        
        case .firstBefore:
            guard date > elements.first!.end else { return nil }
            
            if date > upperBound! { return elements.last }
            
            if
                let idxOfOn = elements
                    .firstIndex(where: { $0.contains(date) })
            {
                // there's an element contaning the date…
                // …we return the one before!
                // This is safe since we've guarded against
                // date smaller than or equal first element's end
                return elements[idxOfOn - 1]
            } else {
                // No element contains the date,
                // hence we return the last element whose end is smaller
                // than date!
                return elements
                    .last(where: { $0.end < date })
            }
        }
    }
    
    public func schedule(in dateInterval: DateInterval, queue: DispatchQueue?, then completion: @escaping (Result<[Self.Element], Swift.Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var result: Result<[DateInterval], Swift.Error> = .success([])
            if
                !self.isEmpty,
                dateInterval.end > self.lowerBound!,
                dateInterval.start < self.upperBound!,
                let idxOfFirstIn = self.elements
                    .firstIndex(where: { $0.start >= dateInterval.start }),
                let idxOfLastIn = self.elements
                    .lastIndex(where: { $0.end <= dateInterval.end })
            {
                let rangeOfContainedElements = idxOfFirstIn...idxOfLastIn
                let containedElements = Array(self.elements[rangeOfContainedElements])
                result = .success(containedElements)
            }
            
            dispatchResultCompletion(result: result, queue: queue, completion: completion)
        }
    }
    
}
