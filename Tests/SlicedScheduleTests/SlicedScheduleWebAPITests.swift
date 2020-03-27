//
//  SlicedScheduleTests
//  SlicedScheduleWebAPITests.swift
//
//  Created by Valeriano Della Longa on 27/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import SlicedSchedule

final class SlicedScheduleWebAPITests: XCTestCase {
    var sut: SlicedSchedule!
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super .setUp()
        
        sut = try! SlicedSchedule(givenValidElementsRandomly())
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenValidElementsRandomly() -> [DateInterval] {
        let countOfElements = Int.random(in: 1..<100)
        let minutesDuration = Int.random(in: 60..<121)
        let shiftBetweenElements = Int.random(in: 0...minutesDuration)
        
        let durationInSeconds = TimeInterval(60*minutesDuration)
        let shiftInSeconds = TimeInterval(60*shiftBetweenElements)
        
        return (0..<countOfElements).map { elementIdx in
            let start = Date(timeIntervalSinceReferenceDate: TimeInterval(elementIdx) * durationInSeconds + shiftInSeconds)
            return DateInterval(start: start, duration: durationInSeconds)
        }
    }
    
    // MARK: - When
    
    // MARK: - Tests
    func test_codable_encode_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut))
    }
    
    func test_webAPI_encode_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        encoder.setWebAPI(version: .v1)
        
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut))
    }
    
    func test_codable_decode_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut)
        
        // then
        XCTAssertNoThrow(try decoder.decode(SlicedSchedule.self, from: data))
    }
    
    func test_webAPI_decode_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut)
        
        // then
        XCTAssertNoThrow(try decoder.decode(SlicedSchedule.self, from: data))
    }
    
    func test_codable_whenEncodeThenDecode_decodedValueIsSame() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut)
        let result = try! decoder.decode(SlicedSchedule.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.elements, result.elements)
    }
    
    func test_webAPI_whenEncodeThenDecode_decodedValueIsSame() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut)
        let result = try! decoder.decode(SlicedSchedule.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.elements, result.elements)
    }
    
    static var allTests = [
        ("test_codable_encode_doesntThrow", test_codable_encode_doesntThrow),
        ("test_webAPI_encode_doesntThrow", test_webAPI_encode_doesntThrow),
        ("test_codable_decode_doesntThrow", test_codable_decode_doesntThrow),
        ("test_webAPI_decode_doesntThrow", test_webAPI_decode_doesntThrow),
        ("test_codable_whenEncodeThenDecode_decodedValueIsSame", test_codable_whenEncodeThenDecode_decodedValueIsSame),
        ("test_webAPI_whenEncodeThenDecode_decodedValueIsSame", test_webAPI_whenEncodeThenDecode_decodedValueIsSame),
        
    ]
}
