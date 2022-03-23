//
//  ApiError.swift
//  CloudTips
//
//

import Foundation

enum ApiError: LocalizedError {
	case unknownUrl
	case networkError
	case incorrectResponseJson
	case apiError(String)
	case unauthorized
	case failure
    case invalidGrant
}

extension ApiError {
	var errorDescription: String? {
		var desctiption: String?
		switch self {
		case .apiError(let message):
			desctiption = message
		default:
			break
		}
		return desctiption
	}
}

// "{\"error\":\"invalid_grant\"}"
struct SomeError: Decodable {
    let error: String
}
