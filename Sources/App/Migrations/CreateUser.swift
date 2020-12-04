//
//  CreateUser.swift
//
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("name", .string, .required)
            .field("lastname", .string, .required)
            .field("nickname", .string, .required)
            .field("password", .string, .required)
            .unique(on: "email", name: "no_duplicate_emails")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("people").delete()
    }
}
