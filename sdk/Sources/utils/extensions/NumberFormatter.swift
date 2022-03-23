//
//  NumberFormatter.swift
//  CloudTips
//
//  Created by Sergey Kovrizhkin on 06.02.2021.
//

import Foundation

extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension NumberFormatter {
	
	static func formatCurrency(value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "ru_RU")
		formatter.numberStyle = .currency
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		let result = formatter.string(from: value as NSNumber)
		return result!
	}
	
	static func formatPercent(value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.numberStyle = .percent
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		let result = formatter.string(from: value as NSNumber)
		return result!
	}
	
	static func formatCurrencyWithSign(value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "ru_RU")
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 2
	//	formatter.positivePrefix = formatter.plusSign + " "
		formatter.negativePrefix = formatter.minusSign + " "
		let result = formatter.string(from: value as NSNumber)
		return result!
	}
}
