//
//  SlicedScheduleTests
//  SliceScheduleScheduleTests.swift
//  
//
//  Created by Valeriano Della Longa on 27/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import SlicedSchedule
import Schedule

final class SliceScheduleScheduleTests: XCTestCase {
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    var sut: SlicedSchedule!
    
    // MARK: Tests lifecycle
    override func setUp() {
        super.setUp()
        
        let randomDate = givenRandomDate()
        let countOfElements = Int.random(in: 5..<101)
        let minutesDuration = Int.random(in: 60..<121)
        let duration: TimeInterval = TimeInterval(minutesDuration) * 60.0
        let minutesShift = Int.random(in: 5..<61)
        let shift: TimeInterval = 60.0 * TimeInterval(minutesShift)
        let elements: [DateInterval] = (0..<countOfElements)
            .map {
                let start = randomDate.addingTimeInterval(TimeInterval($0) * (duration + shift))
                return DateInterval(start: start, duration: duration)
        }
        
        sut = try! SlicedSchedule(elements)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenRandomDate() -> Date {
        let randomMinutes = TimeInterval(Int.random(in: 0..<100_000))
        let randomDistance = Bool.random() ? -60 * randomMinutes : 60 * randomMinutes
        
        return refDate.addingTimeInterval(randomDistance)
    }
    
    // MARK: - When
    func whenIsEmpty() {
        sut = SlicedSchedule()
    }
    
    func whenElementsAreContiguous() {
        let randomDate = givenRandomDate()
        let countOfElements = Int.random(in: 5..<101)
        let minutesDuration = Int.random(in: 60..<121)
        let duration: TimeInterval = TimeInterval(minutesDuration) * 60.0
        let elements: [DateInterval] = (0..<countOfElements)
            .map {
                let start = randomDate.addingTimeInterval(TimeInterval($0) * duration)
                return DateInterval(start: start, duration: duration)
        }
        
        sut = try! SlicedSchedule(elements)
    }
    
    // MARK: - Tests
    // MARK: - isEmpty
    func test_isEmpty_returnsElementsIsEmpty() {
        // given
        let emptyTimetable = SlicedSchedule()
        let notEmptyTimetable = try! SlicedSchedule([DateInterval(start: refDate, duration: 3600)])
        // when
        // then
        XCTAssertEqual(emptyTimetable.isEmpty, emptyTimetable.elements.isEmpty)
        XCTAssertEqual(notEmptyTimetable.isEmpty, notEmptyTimetable.elements.isEmpty)
    }
    
    // MARK: - Contains
    func test_contains_whenIsEmpty_returnsFalse()
    {
        // given
        // when
        whenIsEmpty()
        
        // then
        XCTAssertFalse(sut.contains(givenRandomDate()))
    }
    
    func test_contains_whenDateIsLessThanFirstElementStart_returnsFalse()
    {
        // given
        // when
        let date = sut.elements.first!.start.addingTimeInterval(-1.0)
        
        // then
        XCTAssertFalse(sut.contains(date))
    }
    
    func test_contains_whenDateIsGreaterThanLastElementEnd_returnsFalse()
    {
        // given
        // when
        let date = sut.elements.last!.end.addingTimeInterval(1.0)
        
        // then
        XCTAssertFalse(sut.contains(date))
    }
    
    func test_contains_whenDateIsNotContainedInAnyElement_returnsFalse()
    {
        // given
        let distance = sut.elements[0].end.distance(to: sut.elements[1].start)
        // when
        let dateBetweenElements = sut.elements.first!.end.addingTimeInterval(distance / 2.0)
        
        // then
        XCTAssertFalse(sut.contains(dateBetweenElements))
    }
    
    func test_contains_whenDateIsContainedInAnElement_returnsTrue() {
        // given
        let duration = sut.elements.first!.duration
        
        // when
        let dateInElement = sut.elements.first!.start.addingTimeInterval(duration / 2)
        
        // then
        XCTAssertTrue(sut.contains(dateInElement))
    }
    
    // MARK: - schedule(matching:direction:)
    func test_scheduleMatching_whenIsEmpty_returnsNil() {
        // given
        let randomDate = givenRandomDate()
        
        // when
        whenIsEmpty()
        
        // then
        for direction in CalendarCalculationMatchingDateDirection.allCases
        {
            XCTAssertNil(sut.schedule(matching: randomDate, direction: direction))
        }
    }
    
    func test_scheduleMatching_on_whenDateLessThanFirstElementStart_returnsNil()
    {
        // given
        // when
        let date = sut.elements.first!.start.addingTimeInterval(-1.0)
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .on))
    }
    
    func test_scheduleMatching_on_whenDateGreaterThanLastElementEnd_returnsNil()
    {
        // given
        // when
        let date = sut.elements.last!.end.addingTimeInterval(1.0)
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .on))
    }
    
    func test_scheduleMatching_on_whenDateNotContainedByAnyElement_returnsNil()
    {
        // given
        let distance = sut.elements[0].end.distance(to: sut.elements[1].start)
        // when
        let dateBetweenElements = sut.elements.first!.end.addingTimeInterval(distance / 2.0)
        
        // then
        XCTAssertNil(sut.schedule(matching: dateBetweenElements, direction: .on))
    }
    
    func test_scheduleMatching_on_whenDateContainedInElement_returnsElement()
    {
        // given
        let duration = sut.elements.first!.duration
        
        // when
        let dateInElement = sut.elements.first!.start.addingTimeInterval(duration / 2)
        let expectedResult = sut.elements.first!
        let result = sut.schedule(matching: dateInElement, direction: .on)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatching_on_whenDateIsEndOfElementAndStartOfNextElement_returnsNextElement()
    {
        // given
        // when
        whenElementsAreContiguous()
        let date = sut.elements.first!.end
        let expectedResult = sut.elements[1]
        let result = sut.schedule(matching: date, direction: .on)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatching_firstAfter_whenDateIsGreaterThanLastElementStart_returnsNil()
    {
        // given
        // when
        let date = sut.elements.last!.start.addingTimeInterval(1.0)
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .firstAfter))
    }
    
    func test_scheduleMatching_firstAfter_whenDateIsSmallerThanFirstElementStart_returnsFirstElement()
    {
        // given
        // when
        let date = sut.elements.first!.start.addingTimeInterval(-1.0)
        let expectedResult = sut.elements.first!
        let result = sut.schedule(matching: date, direction: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatchingDate_firstAfter_whenDateIsInElementBeforeLastElement_returnsNextElement()
    {
        // given
        let idxOfElementBeforeEnd = sut.elements.count - 2
        
        // when
        let date = sut.elements[idxOfElementBeforeEnd].end.addingTimeInterval(-1.0)
        let expectedResult = sut.elements.last!
        let result = sut.schedule(matching: date, direction: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatching_firstAfter_whenDateIsBetweenTwoElements_returnsElement()
    {
        // given
        let distance = sut.elements.first!.end.distance(to: sut.elements[1].start)
        
        // when
        let date = sut.elements.first!.end.addingTimeInterval(distance / 2)
        let expectedResult = sut.elements[1]
        let result = sut.schedule(matching: date, direction: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatchingDate_firstAfter_whenDateIsEndDateOfElementAndStartOfNextElement_returnsElementAfterNextElement()
    {
        // given
        // when
        whenElementsAreContiguous()
        let date = sut.elements.first!.end
        let expectedResult = sut.elements[2]
        let result = sut.schedule(matching: date, direction: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatchingDate_firstAfter_whenDateIsStartOfLastElement_returnsNil()
    {
        // given
        // when
        var date = sut.elements.last!.start
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .firstAfter))
        
        // when
        whenElementsAreContiguous()
        let idx = sut.elements.count - 1
        date = sut.elements[idx].end
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .firstAfter))
    }
    
    func test_scheduleMatching_firstBefore_whenDateIsSmallerThanFirstElementEnd_returnsNil()
    {
        // given
        // when
        let date = sut.elements.first!.end.addingTimeInterval(-1.0)
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .firstBefore))
    }
    
    func test_scheduleMatching_firstBefore_whenDatIsGreaterThanLastElementEnd_returnsLastElement()
    {
        // given
        // when
        let date = sut.elements.last!.end.addingTimeInterval(1.0)
        let expectedResult = sut.elements.last!
        let result = sut.schedule(matching: date, direction: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_schedule_matching_firstBefore_whenDateIsInElementThatIsNotFirstElement_returnsPreviousElement()
    {
        // given
        // when
        let date = sut.elements[1].start.addingTimeInterval(1.0)
        let expectedResult = sut.elements.first
        let result = sut.schedule(matching: date, direction: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatching_firstBefore_whenDateIsBetweenTwoElements_returnsElement()
    {
        // given
        let distance = sut.elements.first!.end.distance(to: sut.elements[1].start)
        
        // when
        let date = sut.elements.first!.end.addingTimeInterval(distance / 2)
        let expectedResult = sut.elements.first!
        let result = sut.schedule(matching: date, direction: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatchingDate_firstBefore_whenDateIsStartDateOfElementAndEndOfPreviousElement_returnsPreviousElement()
    {
        // given
        // when
        whenElementsAreContiguous()
        let date = sut.elements[1].start
        let expectedResult = sut.elements.first!
        let result = sut.schedule(matching: date, direction: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_scheduleMatchingDate_firstBefore_whenDateIsEndOfFirstElement_returnsNil()
    {
        // given
        // when
        let date = sut.elements.first!.end
        
        // then
        XCTAssertNil(sut.schedule(matching: date, direction: .firstBefore))
    }
    
    // MARK: - schedule(in:queue:then:)
    
    
    static var allTests = [
        ("test_isEmpty_returnsElementsIsEmpty", test_isEmpty_returnsElementsIsEmpty),
        ("test_contains_whenIsEmpty_returnsFalse", test_contains_whenIsEmpty_returnsFalse),
        ("test_contains_whenDateIsLessThanFirstElementStart_returnsFalse", test_contains_whenDateIsLessThanFirstElementStart_returnsFalse),
        ("test_contains_whenDateIsGreaterThanLastElementEnd_returnsFalse", test_contains_whenDateIsGreaterThanLastElementEnd_returnsFalse),
        ("test_contains_whenDateIsNotContainedInAnyElement_returnsFalse", test_contains_whenDateIsNotContainedInAnyElement_returnsFalse),
        ("test_contains_whenDateIsContainedInAnElement_returnsTrue", test_contains_whenDateIsContainedInAnElement_returnsTrue),
        ("test_scheduleMatching_whenEmpty_returnsNil", test_scheduleMatching_whenIsEmpty_returnsNil),
        ("test_scheduleMatching_on_whenDateLessThanFirstElementStart_returnsNil", test_scheduleMatching_on_whenDateLessThanFirstElementStart_returnsNil),
        ("test_scheduleMatching_on_whenDateGreaterThanLastElementEnd_returnsNil", test_scheduleMatching_on_whenDateGreaterThanLastElementEnd_returnsNil),
        ("test_scheduleMatching_on_whenDateNotContainedByAnyElement_returnsNil", test_scheduleMatching_on_whenDateNotContainedByAnyElement_returnsNil),
        ("test_scheduleMatching_on_whenDateContainedInElement_returnsElement", test_scheduleMatching_on_whenDateContainedInElement_returnsElement),
        ("test_scheduleMatching_on_whenDateIsEndOfElementAndStartOfNextElement_returnsNextElement", test_scheduleMatching_on_whenDateIsEndOfElementAndStartOfNextElement_returnsNextElement),
        ("test_scheduleMatching_firstAfter_whenDateIsGreaterThanLastElementStart_returnsNil", test_scheduleMatching_firstAfter_whenDateIsGreaterThanLastElementStart_returnsNil),
        ("test_scheduleMatching_firstAfter_whenDateIsSmallerThanFirstElementStart_returnsFirstElement", test_scheduleMatching_firstAfter_whenDateIsSmallerThanFirstElementStart_returnsFirstElement),
       ("test_scheduleMatchingDate_firstAfter_whenDateIsInElementBeforeLastElement_returnsNextElement", test_scheduleMatchingDate_firstAfter_whenDateIsInElementBeforeLastElement_returnsNextElement),
      ("test_scheduleMatching_firstAfter_whenDateIsBetweenTwoElements_returnsElement", test_scheduleMatching_firstAfter_whenDateIsBetweenTwoElements_returnsElement),
      ("test_scheduleMatchingDate_firstAfter_whenDateIsEndDateOfElementAndStartOfNextElement_returnsElementAfterNextElement", test_scheduleMatchingDate_firstAfter_whenDateIsEndDateOfElementAndStartOfNextElement_returnsElementAfterNextElement),
        ("test_scheduleMatchingDate_firstAfter_whenDateIsStartOfLastElement_returnsNil", test_scheduleMatchingDate_firstAfter_whenDateIsStartOfLastElement_returnsNil),
        ("test_scheduleMatching_firstBefore_whenDateIsSmallerThanFirstElementEnd_returnsNil", test_scheduleMatching_firstBefore_whenDateIsSmallerThanFirstElementEnd_returnsNil),
        ("test_scheduleMatching_firstBefore_whenDatIsGreaterThanLastElementEnd_returnsLastElement", test_scheduleMatching_firstBefore_whenDatIsGreaterThanLastElementEnd_returnsLastElement),
        ("test_schedule_matching_firstBefore_whenDateIsInElementThatIsNotFirstElement_returnsPreviousElement", test_schedule_matching_firstBefore_whenDateIsInElementThatIsNotFirstElement_returnsPreviousElement),
        ("test_scheduleMatching_firstBefore_whenDateIsBetweenTwoElements_returnsElement", test_scheduleMatching_firstBefore_whenDateIsBetweenTwoElements_returnsElement),
        ("test_scheduleMatchingDate_firstBefore_whenDateIsStartDateOfElementAndEndOfPreviousElement_returnsPreviousElement", test_scheduleMatchingDate_firstBefore_whenDateIsStartDateOfElementAndEndOfPreviousElement_returnsPreviousElement),
        ("test_scheduleMatchingDate_firstBefore_whenDateIsEndOfFirstElement_returnsNil", test_scheduleMatchingDate_firstBefore_whenDateIsEndOfFirstElement_returnsNil),
        
    ]
}
