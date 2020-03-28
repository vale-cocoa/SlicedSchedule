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
    private var lowerBound: Date? { return self.elements.first?.start }
    private var upperBound: Date? { return self.elements.last?.end }
    
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
            guard date <= elements.last!.start else { return nil }
            
            if date < lowerBound! { return elements.first }
            
            if
                let idxOfOn = elements
                    .lastIndex(where: { $0.contains(date) })
            {
                
                return idxOfOn < elements.count - 1 ? elements[idxOfOn + 1] : nil
            } else {
                
                return elements
                    .first(where: { $0.start > date })
            }
        
        case .firstBefore:
            guard date >= elements.first!.end else { return nil }
            
            if date > upperBound! { return elements.last }
            
            if
                let idxOfOn = elements
                    .lastIndex(where: { $0.contains(date) })
            {
                
                return idxOfOn > 0 ? elements[idxOfOn - 1] : nil
            } else {
                
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
