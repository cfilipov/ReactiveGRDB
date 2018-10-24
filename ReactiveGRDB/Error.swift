//
//  Error.swift
//  ReactiveGRDBiOS
//
//  Created by Cristian Filipov on 10/23/18.
//  Copyright © 2018 Gwendal Roué. All rights reserved.
//

/// A type-erased error which wraps an arbitrary error instance. This should be
/// useful for generic contexts.
/// https://github.com/antitypical/Result/blob/master/Result/AnyError.swift
public struct AnyError: Swift.Error {
    /// The underlying error.
    public let error: Swift.Error

    public init(_ error: Swift.Error) {
        if let anyError = error as? AnyError {
            self = anyError
        } else {
            self.error = error
        }
    }
}
