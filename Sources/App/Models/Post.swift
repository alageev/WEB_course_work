//
//  Post.swift
//  
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor

final class Post: Model, Content {
    static let schema = "people"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "author_id")
    var authorId: UUID
    
    @OptionalField(key: "reply_to")
    var replyTo: UUID?
    
    @OptionalField(key: "header")
    var header: String?
    
    @Field(key: "text")
    var text: String
    
    @OptionalField(key: "image_link")
    var imageLink: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "number_of_likes")
    var numberOfLikes: UInt64
    
    @Field(key: "number_of_dislikes")
    var numberOfDislikes: UInt64
    
    init() {}
    
    init(id:               UUID?   = nil,
         authorId:         UUID,
         replyTo:          UUID?   = nil,
         header:           String? = nil,
         text:             String,
         imageLink:        String? = nil,
         numberOfLikes:    UInt64  = 0,
         numberOfDislikes: UInt64  = 0) {
        
        self.id = id
        self.authorId = authorId
        self.replyTo = replyTo
        self.header = header
        self.text = text
        self.imageLink = imageLink
        self.numberOfLikes = numberOfLikes
        self.numberOfDislikes = numberOfDislikes
    }
}
