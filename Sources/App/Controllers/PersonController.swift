//
//  PersonController.swift
//  
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor

struct PersonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("user")
        users.post("registration", use: registration)//signing in
        users.post("login",        use: login)//logging in
        
        let secure = users.grouped(Person.JWT.authenticator())
        secure.group(":userID") { users in
//            users.get("posts", use: posts)//user's posts
            users.get(use: getOne)
            users.delete(use: delete)
        }
//        secure.get("authenticate", use: authenticate)
        secure.post("authenticate", use: generateJWT)
        secure.post("test", use: testJWT)
    }

//    func getAll(req: Request) throws -> EventLoopFuture<[Person]> {
//        return Person.query(on: req.db).all()
//    }
    
    func getOne(req: Request) throws -> EventLoopFuture<Person> {
        return Person.find(req.parameters.get("personID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func registration(req: Request) throws -> EventLoopFuture<[String: String]> {
        try Person.NewPerson.validate(content: req)
        let newPerson = try req.content.decode(Person.NewPerson.self)
        guard newPerson.password == newPerson.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = Person(from: newPerson)
        return user.save(on: req.db).map {
                ["token": try! req.jwt.sign(Person.JWT(from: user))]
        }
    }

    func login(req: Request) throws -> EventLoopFuture<[String: String]> {
        let oldPerson = try req.content.decode(Person.OldPerson.self)
        return Person.query(on: req.db).filter(\.$email == oldPerson.email).first().map { person in

            if let person = person {
                if try! Bcrypt.verify(oldPerson.password, created: person.password) {
                    return ["token": try! req.jwt.sign(Person.JWT(from: person))]
                }
            }
            return ["token": ""]
        }
    }
    
    func generateJWT(req: Request) throws -> [String: String] {
        let payload = try req.content.decode(Person.JWT.self)
        return try [
            "token": req.jwt.sign(payload)
        ]
    }
    
    func testJWT(req: Request) throws -> Person.JWT {
        let payload = try req.jwt.verify(as: Person.JWT.self)
        print(payload)
        return payload
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Person.find(req.parameters.get("personID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}

