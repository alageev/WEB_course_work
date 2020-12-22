//
//  User.swift
//
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor
import JWT

final class User: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$author)
    var posts: [Post]

    init() {}

    init(id:        UUID?   = nil,
         email:     String,
         name:      String,
         lastname:  String,
         nickname:  String,
         password:  String
    ) {
        self.id = id
        self.email = email.lowercased()
        self.name = name
        self.lastname = lastname
        self.nickname = nickname
        self.password = password
    }
    
    init(from newUser: User.Create){
        self.id = newUser.id
        self.email = newUser.email.lowercased()
        self.name = newUser.name
        self.lastname = newUser.lastname
        self.nickname = newUser.nickname
        self.password = try! Bcrypt.hash(newUser.password)
    }
}

extension User {
    
    struct Create: Content {
        let id: UUID
        let email: String
        let name: String
        let lastname: String
        let nickname: String
        let password: String
        let confirmPassword: String
    }
    
    struct Check: Content {
        let email: String
        let password: String
    }
    
    struct JWT: Content, Authenticatable, JWTPayload {
        init(from user: User){
            self.id = user.id
            self.email = user.email
            self.name = user.name
            self.lastname = user.lastname
            self.nickname = user.nickname
        }
        
        init(from user: User.Create){
            self.id = user.id
            self.email = user.email
            self.name = user.name
            self.lastname = user.lastname
            self.nickname = user.nickname
        }
        
//        enum CodingKeys: String, CodingKey {
//            case id = "id"
//        }
        
        var token: UUID?
        var id: UUID?
        var email: String
        var name: String
        var lastname: String
        var nickname: String
        
        func verify(using signer: JWTSigner) throws {
            
        }
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
