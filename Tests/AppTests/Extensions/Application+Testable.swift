@testable import App
@testable import XCTVapor

extension Application {
  static func testable() throws -> Application {
    let app = Application(.testing)
    try configure(app)    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    return app
  }
}
extension XCTApplicationTester {
  
  public func login(email: String,
                    password: String,
                    file: StaticString = #file,
                    line: UInt = #line) throws -> Token {
    var request = XCTHTTPRequest(method: .POST,
                                 url: .init(path: "/api/v1/users/login"),
                                 headers: [:],
                                 body: ByteBufferAllocator().buffer(capacity: 0))
    request.headers.basicAuthorization =
      BasicAuthorization(username: email, password: password)
    do {
      let response = try performTest(request: request)
      return try response.content.decode(Token.self)
      
    } catch {
      XCTFail("\(error)", file: (file), line: line)
      throw error
    }
  }
    
  @discardableResult
  public func test(_ method: HTTPMethod,
                   _ path: String,
                   headers: HTTPHeaders = [:],
                   body: ByteBuffer? = nil,
                   loginCredentials: (email: String, rawPassword: String)? = nil,
                   beforeRequest: (inout XCTHTTPRequest) throws -> () = { _ in },
                   afterResponse: (XCTHTTPResponse) throws -> () = { _ in },
                   file: StaticString = #file,
                   line: UInt = #line) throws -> XCTApplicationTester {
    
    var request = XCTHTTPRequest(method: method,
                                 url: URI(path: path),
                                 headers: headers,
                                 body: body ?? ByteBufferAllocator().buffer(capacity: 0) )
    
    if let (email, password) = loginCredentials {
      let token = try login(email: email, password: password, file: file, line: line)
      request.headers.bearerAuthorization = BearerAuthorization(token: token.value)
    }
    
    try beforeRequest(&request)
    do {
      let response = try performTest(request: request)
      try afterResponse(response)
    } catch {
      XCTFail("\(error)", file: (file), line: line)
      throw error
    }
    return self
  }
}


