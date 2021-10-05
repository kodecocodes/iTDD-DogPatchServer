/// Copyright (c) 2021 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import App
import XCTVapor

class TimeInterval_CalendarTests: XCTestCase {
  
  func test_seconds_returnsSameValue() {
    XCTAssertEqual(-42.seconds, -42.0)
    XCTAssertEqual(-2.seconds, -2.0)
    XCTAssertEqual(-1.second, -1.0)
    XCTAssertEqual(0.seconds, 0.0)
    XCTAssertEqual(1.second, 1.0)
    XCTAssertEqual(2.seconds, 2.0)
    XCTAssertEqual(42.seconds, 42.0)
  }
  
  func test_minutes_returnsValueTimes60() {
    XCTAssertEqual(-42.minutes, -42.0 * 60)
    XCTAssertEqual(-2.minutes, -2.0 * 60)
    XCTAssertEqual(-1.minute, -1.0 * 60)
    XCTAssertEqual(0.minutes, 0.0)
    XCTAssertEqual(1.minute, 1.0 * 60)
    XCTAssertEqual(2.minutes, 2.0 * 60)
    XCTAssertEqual(42.minutes, 42.0 * 60)
  }
  
  func test_hours_returnsValueTimes60Times60() {
    XCTAssertEqual(-42.hours, -42.0 * 60 * 60)
    XCTAssertEqual(-2.hours, -2.0 * 60 * 60)
    XCTAssertEqual(-1.hour, -1.0 * 60 * 60)
    XCTAssertEqual(0.hours, 0.0)
    XCTAssertEqual(1.hour, 1.0 * 60 * 60)
    XCTAssertEqual(2.hours, 2.0 * 60 * 60)
    XCTAssertEqual(42.hours, 42.0 * 60 * 60)
  }
  
  func test_days_returnsValueTimes60Times60Time24() {
    XCTAssertEqual(-42.days, -42.0 * 60 * 60 * 24)
    XCTAssertEqual(-2.days, -2.0 * 60 * 60 * 24)
    XCTAssertEqual(-1.day, -1.0 * 60 * 60 * 24)
    XCTAssertEqual(0.days, 0.0)
    XCTAssertEqual(1.day, 1.0 * 60 * 60 * 24)
    XCTAssertEqual(2.days, 2.0 * 60 * 60 * 24)
    XCTAssertEqual(42.days, 42.0 * 60 * 60 * 24)
  }
  
  func test_weeks_returnsValueTimes60Times60Time24Times7() {
    XCTAssertEqual(-42.weeks, -42.0 * 60 * 60 * 24 * 7)
    XCTAssertEqual(-2.weeks, -2.0 * 60 * 60 * 24 * 7)
    XCTAssertEqual(-1.week, -1.0 * 60 * 60 * 24 * 7)
    XCTAssertEqual(0.weeks, 0.0)
    XCTAssertEqual(1.week, 1.0 * 60 * 60 * 24 * 7)
    XCTAssertEqual(2.weeks, 2.0 * 60 * 60 * 24 * 7)
    XCTAssertEqual(42.weeks, 42.0 * 60 * 60 * 24 * 7)
  }
  
  func test_months_returnsValueTimes60Times60Time24Times30Point42() {
    XCTAssertEqual(-42.months, -42.0 * 60 * 60 * 24 * 30.42)
    XCTAssertEqual(-2.months, -2.0 * 60 * 60 * 24 * 30.42)
    XCTAssertEqual(-1.month, -1.0 * 60 * 60 * 24 * 30.42)
    XCTAssertEqual(0.months, 0.0)
    XCTAssertEqual(1.month, 1.0 * 60 * 60 * 24 * 30.42)
    XCTAssertEqual(2.months, 2.0 * 60 * 60 * 24 * 30.42)
    XCTAssertEqual(42.months, 42.0 * 60 * 60 * 24 * 30.42)
  }
  
  func test_months_returnsValueTimes60Times60Time24Times365() {
    XCTAssertEqual(-42.years, -42.0 * 60 * 60 * 24 * 365)
    XCTAssertEqual(-2.years, -2.0 * 60 * 60 * 24 * 365)
    XCTAssertEqual(-1.year, -1.0 * 60 * 60 * 24 * 365)
    XCTAssertEqual(0.years, 0.0)
    XCTAssertEqual(1.year, 1.0 * 60 * 60 * 24 * 365)
    XCTAssertEqual(2.years, 2.0 * 60 * 60 * 24 * 365)
    XCTAssertEqual(42.years, 42.0 * 60 * 60 * 24 * 365)
  }
}
