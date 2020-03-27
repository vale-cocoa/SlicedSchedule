//
//  SlicedSchedule
//  SlicedSchedule+WebAPI.swift
//  
//  Created by Valeriano Della Longa on 26/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import WebAPICodingOptions

extension SlicedSchedule: Codable {
    enum CodingKeys: String, CodingKey {
        case schedule
    }
    
    public init(from decoder: Decoder) throws {
        if
            let codingOptions = decoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions
        {
            switch codingOptions.version {
            case .v1:
                let webInstance = try _WebAPISlicedSchedule(from: decoder)
                self = try Self(webInstance.elements)
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let elements = try container.decode(Array<DateInterval>.self, forKey: .schedule)
            self = try Self(elements)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if
            let codingOptions = encoder.userInfo[WebAPICodingOptions.key] as? WebAPICodingOptions
        {
            switch codingOptions.version {
            case .v1:
                let webInstance = _WebAPISlicedSchedule(self)
                try webInstance.encode(to: encoder)
            }
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(elements, forKey: .schedule)
        }
    }
    
}

fileprivate struct _WebAPISlicedSchedule: Codable {
    struct Element: Codable {
        let start: String
        let end: String
    }
    
    static var formatter: ISO8601DateFormatter {
        let dFormatter = ISO8601DateFormatter()
        dFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dFormatter
    }
        
    let schedule: [Element]
    
    init(_ timetable: SlicedSchedule) {
        self.schedule = timetable.elements
            .map { element in
                let startString = Self.formatter.string(from: element.start)
                let endString = Self.formatter.string(from: element.end)
                
                return Element(start: startString, end: endString)
        }
    }
    
    var elements: [DateInterval] { schedule
        .compactMap { element in
            guard
                let start = Self.formatter.date(from: element.start),
                let end = Self.formatter.date(from: element.end),
                start <= end
                else { return nil }
            
            return DateInterval(start: start, end: end)
        }
    }
    
}
