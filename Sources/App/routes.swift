import Fluent
import Vapor

func routes(_ app: Application) throws {
  try app.register(collection: DogsController())
  try app.register(collection: UsersController())
}
