//
//  Person.swift
//
//
//  Created by Алексей Агеев on 21.10.2020.
//

import Fluent
import Vapor
import JWT

final class Person: Model, Content, Authenticatable {
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
    
    @OptionalField(key: "image_link")
    var imageLink: String?

    init() {}

    init(id:        UUID?   = nil,
         email:     String,
         name:      String,
         lastname:  String,
         nickname:  String,
         password:  String,
         imageLink: String? = nil) {
        
        self.id = id
        self.email = email.lowercased()
        self.name = name
        self.lastname = lastname
        self.nickname = nickname
        self.password = password
        self.imageLink = imageLink
    }
    
    init(from newPerson: Person.NewPerson){
        self.id = UUID()
        self.email = newPerson.email.lowercased()
        self.name = newPerson.name
        self.lastname = newPerson.lastname
        self.nickname = newPerson.nickname
        self.password = try! Bcrypt.hash(newPerson.password)
        self.imageLink = newPerson.imageLink
    }
}

extension Person {
    
    struct NewPerson: Content {
        let email: String
        let name: String
        let lastname: String
        let nickname: String
        let password: String
        let confirmPassword: String
        let imageLink: String?
    }
    
    struct OldPerson: Content {
        let email: String
        let password: String
    }
    
    struct JWT: Content, Authenticatable, JWTPayload {
        init(from person: Person){
            self.id = person.id
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
        }
        
        var id: UUID?
    }
}

//extension Person: ModelAuthenticatable {
//    static let usernameKey = \Person.$email
//    static let passwordKey = \Person.$password
//    
//    func verify(password: String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.password)
//    }
}

extension Person.NewPerson: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension Person.OldPerson: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
