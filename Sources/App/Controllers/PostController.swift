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
        let posts = routes.grouped("post").grouped(User.JWT.authenticator())
        posts.get(use: getAll)
        posts.get("my", use: getUserPosts)
        posts.post(use: addNew)
        posts.group(":postID") { post in
            post.get(use: getPost)
            post.delete(use: delete)
        }
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[Post]> {
        Post.query(on: req.db).with(\.$author).all().map { posts -> [Post] in
            for post in posts {
                post.author.password = ""
            }
            return posts
        }
    }
    
    func getUserPosts(req: Request) throws -> EventLoopFuture<[Post]> {
        guard let uuid = (try req.auth.require(User.JWT.self)).id else {
            throw Abort(.unauthorized)
        }
        
        return Post.query(on: req.db)
            .with(\.$author)
            .all()
            .map { posts -> [Post] in
                var userPosts: [Post] = []
                for post in posts {
                    if post.$author.id == uuid {
                        post.author.password = ""
                        userPosts.append(post)
                    }
                }
                return userPosts
            }
    }
    
    func getPost(req: Request) throws -> EventLoopFuture<[Post]> {
        Post.query(on: req.db).with(\.$author).all()
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

