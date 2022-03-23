//
//  ApiResponse.swift
//  CloudTips
//
//

import Foundation

struct ApiDataResponse<DataType: Decodable>: Decodable {
	let data: DataType?
	let succeed: Bool
}

struct ResponseError: Decodable {
	let errors: [String]
}

struct EmptyResponse: Decodable {}

enum ApiResponse<ResponseType: Decodable>: Decodable {
	case success(ResponseType)
	case failure(ResponseError)
	
	enum CodingKeys: String, CodingKey {
		case errors
		case data
		case succeed
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		do {
			let succeed = try container.decode(Bool.self, forKey: .succeed)
			if !succeed {
				throw ApiError.failure
			}
            if let data = try? container.decode(ResponseType.self, forKey: .data) {
                self = .success(data)
            } else {
                throw ApiError.incorrectResponseJson
            }
		} catch {
            debugPrint(error)
			if let apiError = try? container.decode([String].self, forKey: .errors) {
				self = .failure(ResponseError(errors: apiError))
			} else {
				throw error
			}
		}
	}
}
