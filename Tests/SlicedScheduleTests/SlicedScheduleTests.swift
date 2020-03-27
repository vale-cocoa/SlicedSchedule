//
//  SlicedScheduleTests
//  SlicedScheduleTests.swift
//
//  Created by Valeriano Della Longa on 26/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import SlicedSchedule

final class SlicedScheduleTests: XCTestCase {
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    // MARK: - given
    let validDateIntervals: [DateInterval] = (0..<10)
        .map { DateInterval(start: Date(timeIntervalSinceReferenceDate: TimeInterval(3600*$0)), duration: 3600)
    }
    
    func test_init_setsElementsToEmptyArray() {
        // given
        // when
        let timetable = SlicedSchedule()
        
        // then
        XCTAssertTrue(timetable.elements.isEmpty)
    }
    
    func test_init_whenElementsContainElementsStartingOnSameDate_throws()
    {
        // given
        let elementsStartingOnSameDate = validDateIntervals
            .map { DateInterval(start: $0.start, duration: $0.duration + 1.0) }
        
        // when
        let elements = validDateIntervals + elementsStartingOnSameDate
        
        // then
        XCTAssertThrowsError(try SlicedSchedule(elements.shuffled()))
    }
    
    func test_initWhenElementsContainElementsEndingOnSameDate_throws()
    {
        // given
        let elementsEndingOnSameDate = validDateIntervals
            .map {
                DateInterval(start: $0.start + 1.0, end: $0.end)
        }
        
        // when
        let elements = validDateIntervals + elementsEndingOnSameDate
        
        // then
        XCTAssertThrowsError(try SlicedSchedule(elements.shuffled()))
    }
    
    func test_init_whenGivenElementsContainOverlappingElement_throws()
    {
        // given
        let overlappedDateInterval = DateInterval(start: validDateIntervals.first!.start.addingTimeInterval(-3600), duration: 3601)
        
        // when
        let elements = validDateIntervals + [overlappedDateInterval]
        
        // then
        XCTAssertThrowsError(try SlicedSchedule(elements.shuffled()))
    }
    
    func test_init_whenElementsContainElementsNotOverlappingAndStartingAndEndingOnDifferentDate_doesntThrow()
    {
        // given
        // when
        // then
        XCTAssertNoThrow(try SlicedSchedule(validDateIntervals.shuffled()))
    }
    
    func test_whenInitDoesntThrow_setsElementsInSortedOrder()
    {
        // given
        let elements = validDateIntervals.shuffled()
        
        // when
        let timetable = try! SlicedSchedule(elements)
        
        // then
        XCTAssertEqual(timetable.elements, validDateIntervals)
    }
    
    func test_description_returnsExpectedValue() {
        // given
        let elements = validDateIntervals.shuffled()
        let timetable = try! SlicedSchedule(elements)
        let expectedResultStrings = validDateIntervals
        .compactMap { timetable.formatter.string(from: $0.start, to: $0.end) }
        let expectedResult = "Schedule elements: \(expectedResultStrings)"
        
        // when
        // then
        XCTAssertEqual(timetable.description, expectedResult)
    }
    
    static var allTests = [
        ("test_init_setsElementsToEmptyArray", test_init_setsElementsToEmptyArray),
        ("test_init_whenElementsContainElementsStartingOnSameDate_throws", test_init_whenElementsContainElementsStartingOnSameDate_throws),
        ("test_initWhenElementsContainElementsEndingOnSameDate_throws", test_initWhenElementsContainElementsEndingOnSameDate_throws),
        ("test_init_whenGivenElementsContainOverlappingElement_throws", test_init_whenGivenElementsContainOverlappingElement_throws),
        ("test_init_whenElementsContainElementsNotOverlappingAndStartingAndEndingOnDifferentDate_doesntThrow", test_init_whenElementsContainElementsNotOverlappingAndStartingAndEndingOnDifferentDate_doesntThrow),
        ("test_whenInitDoesntThrow_setsElementsInSortedOrder", test_whenInitDoesntThrow_setsElementsInSortedOrder),
        ("test_description_returnsExpectedValue", test_description_returnsExpectedValue),
        
    ]
}
