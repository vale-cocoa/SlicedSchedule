# SlicedSchedule

A concrete `Schedule` type contaning a finite number of elements.

## Introduction
This concrete `Schedule` type is used to represent a finite timetable, that is its elements are in finite number. Each element could vary in duration, and not occour at the same rate in time, but cannot overlap on each other as far as on their start and end date (those would be adjacent elements).

## Usage
The `SlicedSchedule` type conforms to `Schedule` protocol, hence it provides all the functionalities to effectively work with instances of this type as `Schedule` instances. 
To create instances, two initializers are provived: `init`, which returns an instance with no elements, and `init(_:)` which accepts a `Collection` of  `DateInterval` elements (aka `Schedule.Element`); upon validition of the contained elements, it will either return a new instance or throw an `SlicedSchedule.Error.oneOrMoreInvalidElements` error.

### Elements validation upon initialization from a `Collection`
The validation process of given schedule elements consists on 
* checking that there are no duplicates; 
* checking that there aren't elements sharing the same `start`  and `end` date;
* checking, after sorting in ascending order by `start` date the given `Collection`, that no element has its end date greater than the next element's `start` date, thus effectively checking that elements don't overlap over mere adjacency.

### Examples of initialization via `Collection` of `DateInterval`
```swift
let refDate = Date(timeIntervalSinceReferenceDate: 0)

// These parameters will make the initializer throw
let elementsWithDuplicates: [DateInterval] = (1...2)
    .map { _ in DateInterval(start: refDate, duration: 3600) }
    .shuffled()
    
let elementsOverlapping: [DateInterval] = (0..<2)
    .map { 
        DateInterval(start: refDate.addingTimeInterval($0 * 3600), duration: 3601) 
    }
    .suffled()
    
let timetable1 = try? SlicedSchedule(elementsWithDuplicates)
let timetable2 = try? SlicedSchedule(elementsOverlapping)
// both will be nil since initializer throws for both given collections

// This parameter value validates correctly:
let validAdjacentElements: [DateInterval] = (0..<24)
    .map {
    DateInterval(start: refDate.addingTimeInterval($0 * 3600), duration: 3600)
    }
    .shuffled()
    
let timetable3 = try? SlicedSchedule(validAdjacentElements)
// Returns a non nil value since initializer won't throw
```
