import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SlicedScheduleTests.allTests),
        testCase(SlicedScheduleWebAPITests.allTests),
        testCase(SliceScheduleScheduleTests.allTests),
        
    ]
}
#endif
