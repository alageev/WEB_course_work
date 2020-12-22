//
//  Post.swift
//  
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor

final class Post: Model, Content {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "author")
    var author: User
    
//    @OptionalParent(key: "reply_to")
//    var replyTo: Post?
    
//    @Children(for: \.$replyTo)
//    var replies: [Post]
    
    @Field(key: "header")
    var header: String?
    
    @Field(key: "text")
    var text: String
    
//    @Timestamp(key: "created_at", on: .create)
//    var createdAt: Date?
//
//    @Field(key: "number_of_likes")
//    var numberOfLikes: Int64
//
//    @Field(key: "number_of_dislikes")
//    var numberOfDislikes: Int64
    
    init() {}
    
    init(id:               UUID,
         author:           UUID,
//         replyTo:          UUID?   = nil,
         header:           String,
         text:             String//,
//         numberOfLikes:    Int64  = 0,
//         numberOfDislikes: Int64  = 0
    ) {
        
        self.id = id
        self.$author.id = author
//        self.$replyTo.id = replyTo
        self.header = header
        self.text = text
//        self.numberOfLikes = numberOfLikes
//        self.numberOfDislikes = numberOfDislikes
    }
}

struct UserPost: Decodable {
    let id: String
    let authorId: String
    let header: String
    let text: String
}
