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
    static let schema = "people"
    
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
    
//    @OptionalField(key: "image_link")
//    var imageLink: String?

    init() {}

    init(id:        UUID?   = nil,
         email:     String,
         name:      String,
         lastname:  String,
         nickname:  String,
         password:  String,
//         imageLink: String? = nil
    ) {
        
        self.id = id
        self.email = email.lowercased()
        self.name = name
        self.lastname = lastname
        self.nickname = nickname
        self.password = password
//        self.imageLink = imageLink
    }
    
    init(from newUser: User.NewUser){
        self.id = newUser.id
        self.email = newUser.email.lowercased()
        self.name = newUser.name
        self.lastname = newUser.lastname
        self.nickname = newUser.nickname
        self.password = try! Bcrypt.hash(newUser.password)
//        self.imageLink = newUser.imageLink
    }
}

extension User {
    
    struct NewUser: Content {
        let id: UUID
        let email: String
        let name: String
        let lastname: String
        let nickname: String
        let password: String
        let confirmPassword: String
//        let imageLink: String?
    }
    
    struct OldUser: Content {
        let email: String
        let password: String
    }
    
    struct JWT: Content, Authenticatable, JWTPayload {
        init(from person: User){
            self.id = person.id
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
        }
        
        var id: UUID?
        
        func verify(using signer: JWTSigner) throws {
        }
    }
}

//extension User: ModelAuthenticatable {
//    static let usernameKey = \User.$email
//    static let passwordHashKey = \User.$password
//    
//    func verify(password: String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.password)
//    }
//}

extension User.NewUser: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User.OldUser: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
