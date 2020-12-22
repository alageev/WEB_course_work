//
//  CreatePost.swift
//  
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent

struct CreatePost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("posts")
            .id()
            .field("author",             .uuid,   .required, .references("users", "id"))
//            .field("reply_to",           .uuid,              .references("posts", "id"))
            .field("header",             .string, .required)
            .field("text",               .string, .required)
//            .field("created_at",         .datetime)
//            .field("number_of_likes",    .int64,  .required)
//            .field("number_of_dislikes", .uint64, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("posts").delete()
    }
}
