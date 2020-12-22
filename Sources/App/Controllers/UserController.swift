//
//  UserController.swift
//  
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor
import JWT

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("user")
        users.post("registration", use: registration)//signing in
        users.post("login",        use: login)//logging in
        
        let secure = users.grouped(User.JWT.authenticator())
        secure.get("self", use: selfUser)
        secure.group(":userID") { users in
//            users.get("posts", use: posts)//user's posts
            users.get(use: getOne)
//            users.delete(use: delete)
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
        
        do {
            try User.Create.validate(content: req)
        } catch {
            throw Abort(.notAcceptable, reason: "Invalid data")
        }
        
        var create: User.Create
        do {
            create = try req.content.decode(User.Create.self)
        } catch {
            throw Abort(.notAcceptable, reason: "Cannot decode data")
        }
        
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let user = User(from: create)
        
        return user.save(on: req.db).flatMapThrowing {
            do {
                return ["token": try req.jwt.sign(User.JWT(from: user))]
            } catch {
                throw Abort(.internalServerError)
            }
        }
    }

    func login(req: Request) throws -> EventLoopFuture<[String: String]> {
        
        var check: User.Check
        
        do {
            check = try req.content.decode(User.Check.self)
        } catch {
            throw Abort(.notAcceptable, reason: "Cannot decode data")
        }
        
        return User.query(on: req.db)
            .filter(\.$email == check.email.lowercased())
            .first()
            .unwrap(or: Abort(.badRequest, reason: "User not found"))
            .flatMapThrowing { user -> [String: String] in
                var passwordIsCorrect: Bool
                
                do {
                    passwordIsCorrect = try Bcrypt.verify(check.password, created: user.password)
                } catch {
                    throw Abort(.internalServerError, reason: "Cannot calculate hash")
                }
                
                guard passwordIsCorrect else {
                    throw Abort(.unauthorized, reason: "Incorrect password")
                }
                
                do {
                    return ["token": try req.jwt.sign(User.JWT(from: user))]
                } catch {
                    throw Abort(.internalServerError, reason: "Cannot sign jwt")
                }
        }
    }
    
//    func posts(req: Request) throws -> EventLoopFuture<[Post]> {
//        User.query(on: req.db).with(\.$posts).all()
//        Post.query(on: req.db).with(\.$author).all()
//        if let userId = req.parameters.get("userID"),
//           let userUUID = UUID(userId) {
////            return Post.query(on: req.db)
////                .filter(\.$authorId == userUUID)
//////                .filter(\.$replyTo == nil)
////                .all()
//            return Posts
//        }
//        throw Abort(.badRequest, reason: "User not found")
//    }
    
//    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return User.find(req.parameters.get("personID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
//    }
}

