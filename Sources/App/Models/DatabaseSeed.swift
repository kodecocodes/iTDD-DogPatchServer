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

import FluentPostgreSQL
import Foundation
import Vapor

public struct DatabaseSeed: Migration {
  public typealias Database = PostgreSQLDatabase
  public static let mandaID = "6c739af2-34fc-41aa-B456-d6c2812e58d7"
  public static let vickiID = "3e590d1b-73b5-45a6-9806-4d52a70dec22"
  
  public static var imageFileManager: ImageFileManager = .default
  
  public static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
    return prepareUsers(on: conn).then { users in
      self.prepareDogs(on: conn)
      }.transform(to: ())
  }
  
  public static func prepareUsers(on conn: PostgreSQLConnection) -> Future<[User]> {
    
    let users = [
      User(id: UUID(DatabaseSeed.vickiID),
           about: "Ever since her 2018 debut, Vicki has been breeding prize-winning poodles.\n\nRay didn’t think she could do it, but she really showed him!",
           email: "vicki@example.com",
           name: "Vicki Wenderlich",
           password: Environment.get("USER_VICKI_PASSWORD") ?? "vickiPassword123#",
           profileImageURL: URL(string: "https://live.staticflickr.com/65535/48259248522_6645c2f9f3_m.png")!), // imageFileManager.imageURL(forPublicPath: "users/\(DatabaseSeed.vickiID)/profile-images/Vicki.png")),
      
      User(id: UUID(DatabaseSeed.mandaID),
           about: "Manda loves dogs big and small! Unfortunately, she has too many, and they have taken over her home...",
           email: "manda@example.com",
           name: "Manda",
           password: Environment.get("USER_MANDA_PASSWORD") ?? "mandaPassword123#",
           profileImageURL: URL(string: "https://live.staticflickr.com/65535/48259249582_58c1a06037.png")!)
    ]
    return users.reduce([Future<User>]()) { return $0 + [$1.create(on: conn)]}.flatten(on: conn)
  }
  
  public static func prepareDogs(on conn: PostgreSQLConnection) -> EventLoopFuture<[Dog]> {
    
    let vickiRating = Review.maxReviewValue
    let mandaRating = Review.defaultReviewValue
    let dogs = [
      Dog(id: nil,
          sellerID: UUID(DatabaseSeed.vickiID)!,
          about: "Lulu’s parents are pure-bred Poodles, and her mother is the 2018 best-in-show Poodle-Doodle winner. Her father is a good-for-nothing, lazy dog. Fortunately, Lulu takes after her mother, most of the time.",
          breed: "Poodle",
          breederRating: vickiRating,
          cost: Decimal(225.99),
          gender: .female,
          imageURL: URL(string: "https://live.staticflickr.com/65535/48259180361_e385cbaa94_m.png")!,
          name: "Lulu",
          relativeBirthday: 6.0.months,
          relativeCreation: 4.0.hours),
      
      Dog(id: nil,
          sellerID: UUID(DatabaseSeed.mandaID)!,
          about: "Joey is a pure-bred Doberman Pinscher. By which I mean, he was feed bread, and his father a Doberman! Be careful, his father is huge...! Joey is best for someone with a lot of outdoor space.",
          breed: "Doberman Mix",
          breederRating: mandaRating,
          cost: Decimal(399.99),
          gender: .male,
          imageURL: URL(string: "https://live.staticflickr.com/65535/48259249117_2b761a6f6f_m.png")!,
          name: "Joey",
          relativeBirthday: 3.0.months,
          relativeCreation: 6.0.hours),
      
      Dog(id: nil,
          sellerID: UUID(DatabaseSeed.mandaID)!,
          about: "Snowball is a go-getter kind of dog. You'll be very happy with him if you like energetic dogs. He enjoys chasing sticks, balls, frisbees, really anything that you throw! If you get Snowball, and you manage to find my keys, please send those back.",
          breed: "Lab mix",
          breederRating: mandaRating,
          cost: Decimal(199.99),
          gender: .male,
          imageURL: URL(string: "https://live.staticflickr.com/65535/48259249007_0e59e44318_m.png")!,
          name: "Snowball",
          relativeBirthday: 8.0.months,
          relativeCreation: 1.0.days),
      
      Dog(id: nil,
          sellerID: UUID(DatabaseSeed.mandaID)!,
          about: "Jack is a chill, fun-loving kinda dog. He's the kinda dog that likes piña coladas and dancin' in the rain.",
          breed: "German Shepherd",
          breederRating: mandaRating,
          cost: Decimal(399.99),
          gender: .male,
          imageURL: URL(string: "https://live.staticflickr.com/65535/48259180871_271e9cae35_m.png")!,
          name: "Jack",
          relativeBirthday: 1.0.year,
          relativeCreation: 3.0.days),
    ]
    return dogs.reduce([Future<Dog>]()) { return $0 + [$1.save(on: conn)]}.flatten(on: conn)
  }
  
  public static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
    return .done(on: conn)
  }
}
