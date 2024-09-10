//
//  CustomDateFormatter.swift
//  ImageFeed
//
//  Created by Егор Галкин on 2024-09-10.
//

import Foundation

final class CustomDateFormatter {
    static let shared = CustomDateFormatter()
    private init() {}
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    lazy var iso8601DateFormatter = ISO8601DateFormatter()
}
