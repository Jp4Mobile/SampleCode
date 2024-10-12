import SwiftUI
import UIKit

/*
 # Sample Code Playground

 This accompanies the *Oct 27, 2024* post on `Enums`.
 */

/// Enums are one of my favorite parts of  the Swift language. They're one of the most powerful value-based objects.

/// ## Simple Enums

/// A simple enum for choosing colors.
enum ColorSimple {
    case red, orange, yellow, green, blue, purple
}

/*
 This can be nice, but if the programmer wants to offer color choices, they'll have to convert the enum variable to be a name.
 */
func name(from color: ColorSimple) -> String {
    switch color {
    case .red:
        return "Red"
    case .orange:
        return "Orange"
    case .yellow:
        return "Yellow"
    case .green:
        return "Green"
    case .blue:
        return "Blue"
    case .purple:
        return "Purple"
    }
}

/*
 This works, but it's repetitive, and if you actually want to get the color from that, it's going to be another lookup function.

 Happily, Swift enums can have raw values and functions, which will allow something like this.
 */

/// ## Enum with raw values

/// An enum with raw String values
enum ColorRaw: String {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
}

/*
 Now, we can leverage that to give us a displayable name much more easily.
 */
extension ColorRaw {
    /// Display name of the color cases
    var displayName: String {
        self.rawValue.capitalized
    }
}

/*
 Enums can conform to protocols, which can also be extremely useful.
 */

extension ColorRaw: CustomStringConvertible, CaseIterable {
    var description: String {
        displayName
    }
}

print(ColorRaw.allCases)

/*
 Thus, `ColorRaw.red.displayName` == "Red", which would allow to display them much more easily.

 As you can see, enums may have computed properties, such as `displayName` in this example. Or they could have functions, such as:
 */

extension ColorRaw {
    /// UIKit Colors
    func uiColor() -> UIColor {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        }
    }

    // SwiftUI Colors
    func swiftUIColor() -> Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        }
    }
}

/// ## Enums with Associated Values
/*
 One of my favorite features of enums is associated values, which can ensure that you have valid parameters to pass into function arguments more clearly.

 Let's look at the date formats:

 ie; (yyyy-MM-dd), (yyyy-MM-dd HH:mm), (yyyy-MM-dd HH:mm thru HH:mm), (yyyy-MM-dd HH:mm-HH:mm), and (yyyy-MM-dd HH:mm thru yyyy-MM-dd HH:mm)
 */
enum DateFormatsLengthy {
    /// YMD
    /// ie; (yyyy-MM-dd)
    case date(Int, Int, Int)
    /// YMD HM
    /// ie; (yyyy-MM-dd HH:mm)
    case dateTime(Int, Int, Int, Int, Int)
    /// YMD HM HM
    /// ie; (yyyy-MM-dd HH:mm-HH:mm) or (yyyy-MM-dd HH:mm thru HH:mm)
    case dateTimeEnd(Int, Int, Int, Int, Int, Int, Int)
    /// YMD HM YMD HM
    /// ie; (yyyy-MM-dd HH:mm thru yyyy-MM-dd HH:mm)
    case dateTimeDateTime(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)
}

/*
 While that would work, it will be a pain in the neck to work with. Positional arguments, can be difficult. Using structures would make this much easier to work with.
 */
struct DateParameter {
    let year: Int
    let month: Int
    let day: Int
}

struct TimeParameter {
    let hour: Int
    let minute: Int
}

struct DateTimeParameter {
    let date: DateParameter
    let time: TimeParameter
}

struct DateTimeEndParameter {
    let date: DateParameter
    let time: TimeParameter
    let endTime: TimeParameter
}

struct DateTimeDateTimeParameter {
    let date: DateParameter
    let time: TimeParameter
    let endDate: DateParameter
    let endTime: TimeParameter
}

/*
 Now using these structures, we see that the enums are a little cleaner and easier to work with.
 */
enum DateFormats {
    /// YMD
    /// ie; (yyyy-MM-dd)
    case date(DateParameter)
    /// YMD HM
    /// ie; (yyyy-MM-dd HH:mm)
    case dateTime(DateTimeParameter)
    /// YMD HM HM
    /// ie; (yyyy-MM-dd HH:mm-HH:mm) or (yyyy-MM-dd HH:mm thru HH:mm)
    case dateTimeEnd(DateTimeEndParameter)
    /// YMD HM YMD HM
    /// ie; (yyyy-MM-dd HH:mm thru yyyy-MM-dd HH:mm)
    case dateTimeDateTime(DateTimeDateTimeParameter)
}

/// ## Enums in arguments
/*
 Another useful use of enums is as parameters in functions. This will be used much more, when I do show more of the infrastructure work with the models that we've just created in a subsequent post.
 */
extension Date {
    /// TaskMaster specific date formats
    enum TMDateFormat {
        /// Date only in a YMD format
        /// ie; (yyyy-MM-dd)
        case date
        /// Date only in a YMDHM format
        /// ie; (yyyy-MM-dd HH:mm)
        case dateTime

        var format: String {
            switch self {
            case .date:
                return "yyyy-MM-dd"
            case .dateTime:
                return "yyyy-MM-dd HH:mm"
            }
        }
    }

    // MARK: - Output formatted Strings
    func string(format: TMDateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }
}

/*
 Let's see it in use.
 */
print(Date().string(format: .date))
print(Date().string(format: .dateTime))

/// ## Incidental use of enums
/*
 Another useful thing about enums is that they don't have initializers, so they're great for static constants.
 */
enum Constant {
    static let welcomeMessage = NSLocalizedString("Welcome", comment: "Welcome Screen Title")

    // They can even be nested
    enum Welcome {
        static let title = NSLocalizedString("Welcome", comment: "Welcome Screen Title")
    }

    enum Settings {
        static let title = NSLocalizedString("Settings", comment: "Settings Screen Title")
        static let license = NSLocalizedString("License", comment: "Open Source License Title")
        static let privacy = NSLocalizedString("Privacy", comment: "Privacy Policy Title")
    }
}

print(Constant.welcomeMessage)
print(Constant.Welcome.title)
print(Constant.Settings.title)
[Constant.Settings.license, Constant.Settings.privacy].forEach { print("|\t" + $0) }
