//
//  DateExtensionsTests.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 10/13/24.
//

import XCTest

@testable import TaskManager

final class DateExtensionsTests: XCTestCase {

    // MARK: - Init Tests
    // MARK: Date initializers
    func test_init_fromDate_withValidInput_returnsDate() {
        let dateFromYMD = Date(format: .date, "2024-10-31")
        let dateFromParameters = Date(date: .init(year: 2024, month: 10, day: 31))
        XCTAssertEqual(dateFromYMD, dateFromParameters)
    }

    func test_init_fromDate_hasMidnightTime() {
        let datefromYMD = Date(format: .date, "2024-10-31")
        let dateFromYMDHM = Date(format: .dateTime, "2024-10-31 00:00")
        XCTAssertEqual(datefromYMD, dateFromYMDHM)
    }

    func test_init_fromDate_withInvalidInput_returnsNil() {
        XCTAssertNil(Date(format: .date, "0-10-31"))
        XCTAssertNil(Date(format: .date, "2024-13-31"))
        XCTAssertNil(Date(format: .date, "2024-10-32"))
        XCTAssertNil(Date(format: .date, "2024-10-31 12:30"))
        XCTAssertNil(Date(format: .date, "unknown with valid 2024-10-31 in it"))
        XCTAssertNil(Date(date: .init(year: 0, month: 10, day: 31)))
        XCTAssertNil(Date(date: .init(year: 2024, month: 13, day: 31)))
        XCTAssertNil(Date(date: .init(year: 2024, month: 10, day: 32)))
    }

    // MARK: - DateTime initializers
    func test_init_fromDateTime_withValidInput_returnsDate() {
        let dateFromYMDHM = Date(format: .dateTime, "2024-10-31 12:30")
        let dateFromParameters = Date(dateTime: .init(date: .init(year: 2024, month: 10, day: 31),
                                                      time: .init(hour: 12, minute: 30)))
        XCTAssertEqual(dateFromYMDHM, dateFromParameters)
    }

    func test_init_fromDateTime_withInvalidInput_returnsNil() {
        XCTAssertNil(Date(format: .dateTime, "2024-10-31"))
        XCTAssertNil(Date(format: .dateTime, "0-10-31 12:30"))
        XCTAssertNil(Date(format: .dateTime, "2024-13-31 12:30"))
        XCTAssertNil(Date(format: .dateTime, "2024-10-32 12:30"))
        XCTAssertNil(Date(format: .dateTime, "2024-10-31 24:30"))
        XCTAssertNil(Date(format: .dateTime, "2024-10-31 12:70"))
        XCTAssertNil(Date(dateTime: .init(date: .init(year: 0, month: 10, day: 31),
                                          time: .init(hour: 12, minute: 30))))
        XCTAssertNil(Date(dateTime: .init(date: .init(year: 2024, month: 13, day: 31),
                                          time: .init(hour: 12, minute: 30))))
        XCTAssertNil(Date(dateTime: .init(date: .init(year: 2024, month: 10, day: 32),
                                          time: .init(hour: 12, minute: 30))))
        XCTAssertNil(Date(dateTime: .init(date: .init(year: 2024, month: 10, day: 31),
                                          time: .init(hour: 24, minute: 30))))
        XCTAssertNil(Date(dateTime: .init(date: .init(year: 2024, month: 10, day: 31),
                                          time: .init(hour: 12, minute: 70))))
    }

    // MARK: - String conversions
    func test_date_formattedString_isCorrect() throws {
        let expectedString = "2024-10-31"
        let sut = try XCTUnwrap(Date(format: .date, expectedString))
        XCTAssertEqual(expectedString, sut.string(format: .date))
    }

    func test_dateTime_formattedString_isCorrect() throws {
        let expectedString = "2024-10-31 12:30"
        let sut = try XCTUnwrap(Date(format: .dateTime, expectedString))
        XCTAssertEqual(expectedString, sut.string(format: .dateTime))
    }

    // MARK: - Parameter model conversions
    func test_toDateModel_isCorrect() throws {
        let expectedString = "2024-10-31"
        let sut = try XCTUnwrap(Date(format: .date, expectedString))
        XCTAssertEqual(expectedString, sut.toDateParameters()?.formattedDate,
                       expectedString)
        XCTAssertNotEqual(expectedString, sut.toDateTimeParameters()?.formattedDate,
                          expectedString)
    }

    func test_toDateTimeModel_isCorrect() throws {
        let expectedString = "2024-10-31 12:30"
        let sut = try XCTUnwrap(Date(format: .dateTime, expectedString))
        XCTAssertNotEqual(expectedString, sut.toDateParameters()?.formattedDate,
                          expectedString)
        XCTAssertEqual(expectedString, sut.toDateTimeParameters()?.formattedDate,
                       expectedString)
    }
}
