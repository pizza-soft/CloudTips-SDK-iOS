//
//  Formatter.swift
//  CloudTips
//
//  Created by Sergey Kovrizhkin on 04.02.2021.
//

import Foundation


func formattedPhone(_ number: String?) -> String? {
    guard let number = number else { return nil }

    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let mask = "+X (XXX) XXX-XX-XX"

    var result = ""
    var index = cleanPhoneNumber.startIndex
    for ch in mask where index < cleanPhoneNumber.endIndex {
        if ch == "X" {
            result.append(cleanPhoneNumber[index])
            index = cleanPhoneNumber.index(after: index)
        } else {
            result.append(ch)
        }
    }
    return result
}

extension Formatter {
	static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()
	static let iso8601: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]
		return formatter
	}()
}

extension JSONDecoder.DateDecodingStrategy {
    static let customISO8601 = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601withFractionalSeconds.date(from: string) ??
            Formatter.iso8601.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let customISO8601 = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
    }
}

