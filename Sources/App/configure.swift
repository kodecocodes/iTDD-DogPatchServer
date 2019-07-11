/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Authentication
import FluentPostgreSQL
import Vapor

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  try configureServices(&config, &env, &services)
  try configureRouter(&config, &env, &services)
  try configureMiddleware(&config, &env, &services)
  try configureDatabases(&config, &env, &services)
  try configureMigrations(&config, &env, &services)
  try configureCommands(&config, &env, &services)
}

private func configureServices(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  try services.register(AuthenticationProvider())
  try services.register(FluentPostgreSQLProvider())  
}

private func configureRouter(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
}

private func configureMiddleware(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  var middlewares = MiddlewareConfig()
  middlewares.use(FileMiddleware.self)
  middlewares.use(ErrorMiddleware.self)
  services.register(middlewares)
}

private func configureDatabases(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  let databaseConfig: PostgreSQLDatabaseConfig
  
  if let url = Environment.get("DATABASE_URL") {
    databaseConfig = PostgreSQLDatabaseConfig(url: url)!
    
  } else {
    let defaultDatabasePort = (env == .testing) ? 5433 : 5432
    let defaultDatabaseName = (env == .testing) ? "dog-patch-test" : "dog-patch"
    databaseConfig = PostgreSQLDatabaseConfig(
      hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost",
      port: Int(Environment.get("DATABASE_PORT") ?? "\(defaultDatabasePort)") ?? defaultDatabasePort,
      username: Environment.get("DATABASE_USER") ?? "vapor",
      database: Environment.get("DATABASE_DB") ?? defaultDatabaseName,
      password: Environment.get("DATABASE_PASSWORD") ?? "password")
  }
  var databases = DatabasesConfig()
  databases.add(database: PostgreSQLDatabase(config: databaseConfig), as: .psql)
  services.register(databases)
}

private func configureMigrations(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  
  // NOTE: Order matters here -- don't rearrange these migrations willy-nilly ;]
  var migrations = MigrationConfig()
  
  // Model relationships
  migrations.add(model: User.self, database: .psql) // must be created before `Dog`, `Review` and `Token`
  migrations.add(model: Dog.self, database: .psql)
  migrations.add(model: Review.self, database: .psql)
  
  // Authentication relationships
  migrations.add(model: Token.self, database: .psql)
  
  // Seeded migrations - must be added after model declarations
  migrations.add(migration: DatabaseSeed.self, database: .psql) 
  
  // Must be done last
  services.register(migrations)
}

private func configureCommands(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
}
