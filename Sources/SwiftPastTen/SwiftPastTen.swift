import Foundation

public struct SwiftPastTen {
  private var numberFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    return formatter
  }

  public init() { }

  public func tell(time: String) throws -> String {
    let splittedTime = time.split(separator: ":")
    guard splittedTime.count == 2 else {
      throw FormatError.wrongFormat
    }
    let hourAsString = String(splittedTime[0])
    guard let hour = Int(hourAsString), hour < 24 else {
      throw FormatError.wrongFormat
    }
    let minutesAsString = String(splittedTime[1])
    guard let minutes = Int(minutesAsString), minutes < 60 else {
      throw FormatError.wrongFormat
    }

    if hour == 0 && minutes == 0 {
      return "It's midnight."
    }

    if (hour <= 12) {
      return try literalTime(hour: hour, minutes: minutes, period: .AM)
    } else {
      return try literalTime(hour: hour - 12, minutes: minutes, period: .PM)
    }
  }

  private func literalTime(hour: Int, minutes: Int, period: Period) throws -> String {
    switch minutes {
    case 0:
      let literalHour = try self.literalHour(hour: hour)
      switch period {
      case .AM: return "It's \(literalHour) o'clock."
      case .PM: return "It's \(literalHour) o'clock in the afternoon."
      }
    case 15:
      let literalHour = try self.literalHour(hour: hour, period: period)
      return "It's quarter past \(literalHour)."
    case 30:
      let literalHour = try self.literalHour(hour: hour, period: period)
      return "It's half past \(literalHour)."
    case 45:
      let literalHour = try self.literalHourPlusOne(hour: hour, period: period)
      return "It's quarter to \(literalHour)."
    case let x where x % 5 == 0:
      switch x {
      case 0...30:
        return "It's \(try self.literalHourAndThirtyFirstMinutes(hour: hour, minutes: minutes, period: period))."
      default:
        return "It's \(try self.literalHourAndThirtyLastMinutes(hour: hour, minutes: minutes, period: period))."
      }
    default:
      guard let literalMinutes = self.numberFormatter.string(from: NSNumber(value: minutes)) else { throw FormatError.cannotParseNumber }
      let literalMinutesWithPotentialPrefix = minutes < 10 ? "O \(literalMinutes)" : literalMinutes
      if hour == 0 || hour == 12 {
        return "It's \(try self.literalHour(hour: hour)) \(literalMinutesWithPotentialPrefix)."
      }
      return "It's \(try self.literalHour(hour: hour)) \(literalMinutesWithPotentialPrefix) \(period)."
    }
  }

  private func literalHour(hour: Int, period: Period? = nil) throws -> String {
    guard hour != 0 else { return "midnight" }

    guard let literalHour = self.numberFormatter.string(from: NSNumber(value: hour)) else { throw FormatError.cannotParseNumber }
    guard hour != 12 else { return literalHour }

    guard let period = period else { return literalHour }

    return "\(literalHour) \(period)"
  }

  private func literalHourAndThirtyFirstMinutes(hour: Int, minutes: Int, period: Period) throws -> String {
    let hour = try self.literalHour(hour: hour, period: period)
    guard let minutes = self.numberFormatter.string(from: NSNumber(value: minutes)) else { throw FormatError.cannotParseNumber }
    return "\(minutes) past \(hour)"
  }

  private func literalHourAndThirtyLastMinutes(hour: Int, minutes: Int, period: Period) throws -> String {
    let hourPlusOne = try self.literalHourPlusOne(hour: hour, period: period)
    let minutesToNextHour = -(minutes - 60)
    guard let minutes = self.numberFormatter.string(from: NSNumber(value: minutesToNextHour)) else { throw FormatError.cannotParseNumber }
    return "\(minutes) to \(hourPlusOne)"
  }

  private func literalHourPlusOne(hour: Int, period: Period) throws -> String {
    let hourPlusOne = hour + 1
    switch hourPlusOne {
    case 1..<12:
      return try self.literalHour(hour: hourPlusOne, period: period)
    case 12:
      switch period {
      case .AM: return try self.literalHour(hour: 12)
      case .PM: return try self.literalHour(hour: 0)
      }
    default:
      return try self.literalHour(hour: 1, period: .PM)
    }
  }
}

extension SwiftPastTen {
  enum Period: String {
    case AM, PM
  }
}
