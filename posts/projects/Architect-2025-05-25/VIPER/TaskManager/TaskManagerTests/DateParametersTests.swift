//
//  DateParametersTests.swift
//  TaskManagerTests
//
//  Created by Jp LaFond on 10/13/24.
//

import XCTest

@testable import TaskManager

final class DateParametersTests: XCTestCase {
    var sut: TMDateType!

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Parameter Convertible Tests
    func test_dateModel_convertsProperly() throws {
        let model = try XCTUnwrap(halloween.toDateParameters())
        sut = try model.toDateType()

        let halloweenDate = try XCTUnwrap(Date(format: .date, model.formattedDate))
        XCTAssertEqual(sut, .date(halloweenDate))
    }

    func test_dateTimeModel_convertsProperly() throws {
        sut = try halloween.toDateTimeParameters()?.toDateType()
        XCTAssertEqual(sut, .date(halloween))
    }

    func test_dateTimeEndParameter_convertsProperly() throws {
        let endTime = try XCTUnwrap(Date(format: .dateTime, "2024-10-31 13:13"))
        let endTimeModel = try XCTUnwrap(endTime.toDateTimeParameters())
        let halloweenModel = try XCTUnwrap(halloween.toDateTimeParameters())
        let model = DateTimeEndTimeParameters(date: halloweenModel.date,
                                              time: halloweenModel.time,
                                              endTime: endTimeModel.time)
        sut = try model.toDateType()
        XCTAssertEqual(sut, .beginEndDate(halloween, endTime))
    }

    func test_dateTimeDateTimeParameter_convertsProperly() throws {
        let startModel = try XCTUnwrap(stPatricksDay.toDateTimeParameters())
        let endModel = try XCTUnwrap(halloween.toDateTimeParameters())
        let model = DateTimeDateTimeParameters(start: startModel,
                                               end: endModel)
        sut = try model.toDateType()
        XCTAssertEqual(sut, .beginEndDate(stPatricksDay, halloween))
    }

    func test_dateTimeEndParameter_failsWhenStartDateIsAfterEndDate() throws {
        let startModel = try XCTUnwrap(Date(format: .dateTime,
                                            "2024-10-31 13:13")?.toDateTimeParameters())
        let startDate = try XCTUnwrap(startModel.toDateType().startDate)
        let endModel = try XCTUnwrap(Date(format: .dateTime,
                                          "2024-10-31 10:31")?.toDateTimeParameters())
        let endDate = try XCTUnwrap(endModel.toDateType().startDate)

        do {
            sut = try DateTimeEndTimeParameters(date: startModel.date,
                                                time: startModel.time,
                                                endTime: endModel.time).toDateType()
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertEqual(error as? TMError,
                           TMError.endDateNotAfterStartDate(startDate,
                                                            endDate))
        }
    }

    func test_dateTimeDateTimeParameter_failsWhenStartDateIsAfterEndDate() throws {
        let startModel = try XCTUnwrap(Date(format: .dateTime,
                                            "2024-10-31 13:13")?.toDateTimeParameters())
        let startDate = try XCTUnwrap(startModel.toDateType().startDate)
        let endModel = try XCTUnwrap(Date(format: .dateTime,
                                          "2024-10-31 10:31")?.toDateTimeParameters())
        let endDate = try XCTUnwrap(endModel.toDateType().startDate)
        do {
            sut = try DateTimeDateTimeParameters(start: startModel,
                                                 end: endModel).toDateType()
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertEqual(error as? TMError,
                           TMError.endDateNotAfterStartDate(startDate,
                                                            endDate))
        }
    }

    // MARK: formattedData Tests
    func test_dateTimeEndParameterWhenCompact_formatsProperly() throws {
        let model = halloweenNoonToNight(format: .compact)
        XCTAssertEqual(model.formattedDate, "2024-10-31 12:00-18:30")
    }

    func test_dateTimeEndParameterWhenExpanded_formatsProperly() throws {
        let model = halloweenNoonToNight(format: .expanded)
        XCTAssertEqual(model.formattedDate, "2024-10-31 12:00 thru 18:30")
    }

    func test_dateTimeDateTimeParameter_formatsProperly() throws {
        let startModel = try XCTUnwrap(stPatricksDay.toDateTimeParameters())
        let endModel = try XCTUnwrap(halloween.toDateTimeParameters())
        let model = DateTimeDateTimeParameters(start: startModel, end: endModel)
        XCTAssertEqual(model.formattedDate, "2024-03-17 03:17 thru 2024-10-31 10:31")
    }

    // MARK: - TMDateType Tests
    func test_TMDateType_dateFormat_withStartDateOnly_returnsDateFormat() throws {
        let expected = "2024-10-31"
        let sut = try XCTUnwrap(expected.toTMDateType())
        XCTAssertNil(sut.endDate)

        XCTAssertEqual(sut.toFormattedDateString(format: .date), expected)
    }

    func test_TMDateType_dateFormat_withStartAndEndDate_returnsNil() throws {
        let expected = "2024-10-31 10:31-11:30"
        let sut = try XCTUnwrap(expected.toTMDateType())
        XCTAssertNotNil(sut.endDate)

        XCTAssertNil(sut.toFormattedDateString(format: .date))
    }

    func test_TMDateType_dateTimeFormat_withStartDateOnly_returnsDateTimeFormat() throws {
        let expected = "2024-10-31 10:31"
        let sut = try XCTUnwrap(expected.toTMDateType())
        XCTAssertNil(sut.endDate)

        XCTAssertEqual(sut.toFormattedDateString(format: .dateTime), expected)
    }

    func test_TMDateType_dateTimeFormat_withStartAndEndDate_returnsNil() throws {
        let expected = "2024-10-31 10:31-11:30"
        let sut = try XCTUnwrap(expected.toTMDateType())
        XCTAssertNotNil(sut.endDate)

        XCTAssertNil(sut.toFormattedDateString(format: .dateTime))
    }

    func test_TMDateType_dateTimeEndTimeFormat_withStartDateOnly_returnsNil() throws {
        let sut = try XCTUnwrap("2024-10-31".toTMDateType())
        XCTAssertNil(sut.endDate)

        XCTAssertNil(sut.toFormattedDateString(format: .dateTimeEndTime))
    }

    func test_TMDateType_dateTimeEndTimeFormat_withSameDate_returnsDateTimeEndTimeFormat_withSeparator() throws {
        let expectedCompactNoSpaces = "2024-10-31 10:31-11:30"
        let expectedExtendedNoSpaces = "2024-10-31 10:31thru11:30"
        let expectedGrammarExtendedNoSpaces = "2024-10-31 10:31through11:30"
        let expectedCompactSpaces = "2024-10-31 10:31 - 11:30"
        let expectedExtendedSpaces = "2024-10-31 10:31 thru 11:30"
        let expectedGrammarExtendedSpaces = "2024-10-31 10:31 through 11:30"
        let sut = try XCTUnwrap(expectedCompactNoSpaces.toTMDateType())
        XCTAssertNotNil(sut.endDate)

        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeEndTime,
                                                 separator: .compact,
                                                 withSpaces: false), expectedCompactNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeEndTime,
                                                 separator: .extended,
                                                 withSpaces: false), expectedExtendedNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeEndTime,
                                                 separator: .grammarExtended,
                                                 withSpaces: false), expectedGrammarExtendedNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeEndTime,
                                                 separator: .compact,
                                                 withSpaces: true), expectedCompactSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeEndTime,
                                                 separator: .extended,
                                                 withSpaces: true), expectedExtendedSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeEndTime,
                                                 separator: .grammarExtended,
                                                 withSpaces: true), expectedGrammarExtendedSpaces)
    }

    func test_TMDateType_dateTimeEndTimeFormat_withDifferentDate_returnsNil() throws {
        let sut = try XCTUnwrap("2024-10-31 10:31-2024-12-25 11:30".toTMDateType())
        XCTAssertNotNil(sut.endDate)

        XCTAssertNil(sut.toFormattedDateString(format: .dateTimeEndTime))
    }

    func test_TMDateType_dateTimeDateTimeFormat_withStartDateOnly_returnsNil() throws {
        let sut = try XCTUnwrap("2024-10-31".toTMDateType())
        XCTAssertNil(sut.endDate)

        XCTAssertNil(sut.toFormattedDateString(format: .dateTimeDateTime))
    }

    func test_TMDateType_dateTimeEndTimeFormat_withSameDate_returnsDateTimeDateTimeFormat_withSeparator() throws {
        let expectedCompactNoSpaces = "2024-10-31 10:31-2024-10-31 11:30"
        let expectedExtendedNoSpaces = "2024-10-31 10:31thru2024-10-31 11:30"
        let expectedGrammarExtendedNoSpaces = "2024-10-31 10:31through2024-10-31 11:30"
        let expectedCompactSpaces = "2024-10-31 10:31 - 2024-10-31 11:30"
        let expectedExtendedSpaces = "2024-10-31 10:31 thru 2024-10-31 11:30"
        let expectedGrammarExtendedSpaces = "2024-10-31 10:31 through 2024-10-31 11:30"
        let sut = try XCTUnwrap(expectedCompactNoSpaces.toTMDateType())
        XCTAssertNotNil(sut.endDate)

        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .compact,
                                                 withSpaces: false), expectedCompactNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .extended,
                                                 withSpaces: false), expectedExtendedNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .grammarExtended,
                                                 withSpaces: false), expectedGrammarExtendedNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .compact,
                                                 withSpaces: true), expectedCompactSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .extended,
                                                 withSpaces: true), expectedExtendedSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .grammarExtended,
                                                 withSpaces: true), expectedGrammarExtendedSpaces)
    }

    func test_TMDateType_dateTimeEndTimeFormat_withDifferentDates_returnsDateTimeDateTimeFormat_withSeparator() throws {
        let expectedCompactNoSpaces = "2024-10-31 10:31-2024-12-31 11:30"
        let expectedExtendedNoSpaces = "2024-10-31 10:31thru2024-12-31 11:30"
        let expectedGrammarExtendedNoSpaces = "2024-10-31 10:31through2024-12-31 11:30"
        let expectedCompactSpaces = "2024-10-31 10:31 - 2024-12-31 11:30"
        let expectedExtendedSpaces = "2024-10-31 10:31 thru 2024-12-31 11:30"
        let expectedGrammarExtendedSpaces = "2024-10-31 10:31 through 2024-12-31 11:30"
        let sut = try XCTUnwrap(expectedCompactNoSpaces.toTMDateType())
        XCTAssertNotNil(sut.endDate)

        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .compact,
                                                 withSpaces: false), expectedCompactNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .extended,
                                                 withSpaces: false), expectedExtendedNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .grammarExtended,
                                                 withSpaces: false), expectedGrammarExtendedNoSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .compact,
                                                 withSpaces: true), expectedCompactSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .extended,
                                                 withSpaces: true), expectedExtendedSpaces)
        XCTAssertEqual(sut.toFormattedDateString(format: .dateTimeDateTime,
                                                 separator: .grammarExtended,
                                                 withSpaces: true), expectedGrammarExtendedSpaces)
    }
    // MARK: - Helpers
    var stPatricksDay: Date {
        Date(format: .dateTime, "2024-03-17 03:17") ?? Date()
    }
    var halloween: Date {
        Date(format: .dateTime, "2024-10-31 10:31") ?? Date()
    }

    func halloweenNoonToNight(format: DateTimeEndTimeParameters.OutputFormat) -> DateTimeEndTimeParameters {
        .init(date: .init(year: 2024, month: 10, day: 31),
              time: .init(hour: 12, minute: 00),
              endTime: .init(hour: 18, minute: 30),
              outputFormat: format)
    }
}
