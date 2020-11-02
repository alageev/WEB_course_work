//
//  PersonController.swift
//  
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor
import JWT

struct PersonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("user")
        users.post("registration", use: registration)//signing in
        users.post("login",        use: login)//logging in
        
        let secure = users.grouped(User.JWT.authenticator())
        secure.get("self", use: selfUser)
        secure.group(":userID") { users in
            users.get("posts", use: posts)//user's posts
            users.get(use: getOne)
            users.delete(use: delete)
        }
    }

//    func getAll(req: Request) throws -> EventLoopFuture<[User]> {
//        return User.query(on: req.db).all()
//    }
    
    func selfUser(req: Request) throws -> EventLoopFuture<User> {
        guard let userID = try req.jwt.verify(as: User.JWT.self).id else {
            throw Abort(.imATeapot)
        }
        return User.find(userID, on: req.db).unwrap(or: Abort(.imATeapot)).map { user in
            user.password = ""
            return user
        }
    }
    
//    func anotherUser(req: Request)
    
    func getOne(req: Request) throws -> EventLoopFuture<User> {
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func registration(req: Request) throws -> EventLoopFuture<[String: String]> {
        try User.NewUser.validate(content: req)
        let newPerson = try req.content.decode(User.NewUser.self)
        guard newPerson.password == newPerson.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = User(from: newPerson)
        return user.save(on: req.db).map {
                ["token": (try? req.jwt.sign(User.JWT(from: user))) ?? ""]
        }
    }

    func login(req: Request) throws -> EventLoopFuture<[String: String]> {
        let oldPerson = try req.content.decode(User.OldUser.self)
        return User.query(on: req.db)
            .filter(\.$email == oldPerson.email.lowercased())
            .first()
            .unwrap(or: Abort(.badRequest, reason: "User not found"))
            .map { person in
            if (try? Bcrypt.verify(oldPerson.password, created: person.password)) != nil {
                return ["token": try! req.jwt.sign(User.JWT(from: person))]
            }
            return ["token":""]
        }
    }
    
    func posts(req: Request) throws -> EventLoopFuture<[Post]> {
        if let userId = req.parameters.get("userID"),
           let userUUID = UUID(userId) {
            return Post.query(on: req.db)
                .filter(\.$authorId == userUUID)
                .filter(\.$replyTo == nil)
                .all()
        }
        throw Abort(.badRequest, reason: "User not found")
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.find(req.parameters.get("personID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

