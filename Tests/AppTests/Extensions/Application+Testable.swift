/// Copyright (c) 2018 Razeware LLC
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

@testable import App
import FluentPostgreSQL
import Vapor

// MARK: - Reset
extension Application {
  
  public static func reset() throws {
    let revertEnvironment = ["vapor", "revert", "--all", "-y"]
    try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    let migrateEnvironment = ["vapor", "migrate", "-y"]
    try Application.testable(envArgs: migrateEnvironment).asyncRun().wait()
  }
  
  public static func testable(envArgs: [String]? = nil) throws -> Application {
    var config = Config.default()
    var services = Services.default()
    var env = Environment.testing
    
    if let environmentArgs = envArgs {
      env.arguments = environmentArgs
    }
    
    try App.configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    
    try App.boot(app)
    return app
  }
}

// MARK: - Requests & Responses
extension Application {
  public func sendRequest<T>(to path: String,
                             method: HTTPMethod,
                             headers: HTTPHeaders = ["Content-Type": "application/json"],
                             body: T,
                             loggedInUserTuple: (User, String)? = nil) throws -> Response where T: Content {
    
    var headers = headers
    if let (user, rawPassword) = loggedInUserTuple {
      let token = try sendLoginRequest(user: user, rawPassword: rawPassword)
      headers.add(name: .authorization, value: "Bearer \(token.token)")
    }
    
    let httpRequest = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
    let request = Request(http: httpRequest, using: self)
    try request.content.encode(body)
    
    let responder = try self.make(Responder.self)
    return try responder.respond(to: request).wait()
  }
  
  public func sendLoginRequest(user: User, rawPassword: String) throws -> App.Token.Public {
    let credentials = BasicAuthorization(username: user.email, password: rawPassword)
    var tokenHeaders = HTTPHeaders()
    tokenHeaders.basicAuthorization = credentials
    
    let tokenResponse = try self.sendRequest(to: AuthenticationController.rootURI,
                                             method: .POST,
                                             headers: tokenHeaders)
    
    return try tokenResponse.content.syncDecode(Token.Public.self)
  }
  
  public func sendRequest(to path: String,
                          method: HTTPMethod,
                          headers: HTTPHeaders = .init(),
                          loggedInUserTuple: (User, String)? = nil) throws -> Response {
    
    return try sendRequest(to: path,
                           method: method,
                           headers: headers,
                           body: EmptyContent(),
                           loggedInUserTuple: loggedInUserTuple)
  }
  
  public func getResponse<C, T>(to path: String,
                                method: HTTPMethod = .GET,
                                headers: HTTPHeaders = ["Content-Type": "application/json"],
                                body: C,
                                decodeTo type: T.Type,
                                loggedInUserTuple: (User, String)? = nil) throws -> T where C: Content, T: Decodable {
    
    let response = try self.sendRequest(to: path,
                                        method: method,
                                        headers: headers,
                                        body: body,
                                        loggedInUserTuple: loggedInUserTuple)
    
    return try response.content.decode(type).wait()
  }
  
  public func getResponse<T>(to path: String,
                             method: HTTPMethod = .GET,
                             headers: HTTPHeaders = ["Content-Type": "application/json"],
                             decodeTo type: T.Type,
                             loggedInUserTuple: (User, String)? = nil) throws -> T where T: Content {
    
    return try self.getResponse(to: path,
                                method: method,
                                headers: headers,
                                body: EmptyContent(),
                                decodeTo: type,
                                loggedInUserTuple: loggedInUserTuple)
  }
}

public struct EmptyContent: Content {}
