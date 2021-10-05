import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
  if var config = Environment.get("DATABASE_URL")
      .flatMap(URL.init)
      .flatMap(PostgresConfiguration.init) {
  
    var tlsConfig = TLSConfiguration.makeClientConfiguration()
    tlsConfig.certificateVerification = .none
    config.tlsConfiguration = tlsConfig
    app.databases.use(.postgres(configuration: config), as: .psql)
    
  } else {
    let databaseConfig: DatabaseEnvironment =
      app.environment == .testing ? .testing() : .localDebug()
    app.databases.use(
      .postgres(hostname: databaseConfig.hostname,
                port: databaseConfig.port,
                username: databaseConfig.username,
                password: databaseConfig.password,
                database: databaseConfig.database),
      as: .psql)
  }
  
  app.migrations.add(CreateUser())    // add FIRST because it's used by other models
  app.migrations.add(CreateToken())
  app.migrations.add(CreateDog())
    
  if (app.environment != .testing) {
    app.migrations.add(DatabaseSeed())
  }
  
  app.logger.logLevel = .debug
  try app.autoMigrate().wait()
  
  try routes(app)
}

struct DatabaseEnvironment {
  let hostname: String
  let port: Int
  let username: String
  let password: String
  let database: String
  
  static func localDebug() -> DatabaseEnvironment {
    return .init(hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                 port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
                 username: Environment.get("DATABASE_USERNAME") ?? "vapor",
                 password: Environment.get("DATABASE_PASSWORD") ?? "password",
                 database: Environment.get("DATABASE_NAME") ?? "dog-patch")
  }
  
  static func testing() -> DatabaseEnvironment {
    return .init(hostname: "localhost",
                 port: 5433,
                 username: "vapor",
                 password: "password",
                 database: "dog-patch-test")
  }
}
