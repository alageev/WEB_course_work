//
//  PostController.swift
//
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor

struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("post")
        posts.get(use: getAll)
        posts.post(use: addNew)
        posts.group(":postID") { post in
            post.delete(use: delete)
        }
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[Post]> {
        return Post.query(on: req.db).filter(\.$replyTo == nil).all()
    }
    
    func addNew(req: Request) throws -> EventLoopFuture<Post> {
        let post = try req.content.decode(Post.self)
        return post.save(on: req.db).map { post }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Post.find(req.parameters.get("postID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

