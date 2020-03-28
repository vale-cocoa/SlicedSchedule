import XCTest

import SlicedScheduleTests

var tests = [XCTestCaseEntry]()
tests += SlicedScheduleTests.allTests()
tests += SlicedScheduleWebAPITests.allTests()
tests += SliceScheduleScheduleTests.allTests()
XCTMain(tests)
