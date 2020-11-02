import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
        
    app.jwt.signers.use(.hs256(key: Environment.get("SIGNER_SECRET") ?? "signer_secret"))
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .psql)

    app.migrations.add(CreatePerson())
    app.migrations.add(CreatePost())

    // register routes
    try routes(app)
}
