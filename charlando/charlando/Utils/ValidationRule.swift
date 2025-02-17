//
//  ValidationRule.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/04/2024.
//

import Foundation
import ValidatorCore

public struct MatchValidationRule: IValidationRule {
    // MARK: Types

    public typealias Input = String

    // MARK: Properties

    public let matchValue: String

    /// The validation error.
    public let error: IValidationError

    // MARK: Initialization

    public init(matchValue: String, error: IValidationError) {
        self.matchValue = matchValue
        self.error = error
    }

    // MARK: IValidationRule

    public func validate(input: String) -> Bool {
        return input == matchValue
    }
}

