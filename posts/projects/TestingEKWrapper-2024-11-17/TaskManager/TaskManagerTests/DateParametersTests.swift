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
