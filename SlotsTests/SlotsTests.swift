// The MIT License (MIT)
//
// Copyright (c) 2015 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest

import Slots

enum MySlot: SlotType {
  typealias Item = MyItem
  case animal
  case fruit
  case food
}

enum MyItem: String {
  case 🐶, 🐱, 🐭, 🐹, 🐰, 🐵, 🐼
  case 🍎, 🍌, 🍇, 🍉, 🍑, 🍍
  case 🍗, 🍔, 🌭, 🍕, 🍦
}

extension MyItem: CustomStringConvertible {
  var description: String {
    return self.rawValue
  }
}

extension MyItem: Equatable {
  static func == (lhs: MyItem, rhs: MyItem) -> Bool {
    return "\(lhs)" == "\(rhs)"
  }
}

class SlotsTests: XCTestCase {

  var slots: Slots<MySlot>!

  override func setUp() {
    super.setUp()
    self.slots = Slots<MySlot>()
  }

  func testSlots() {
    slots.patterns = [.animal, .fruit, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    XCTAssertEqual(Array(slots), [.🐶])

    slots.patterns = [.animal, .fruit, .fruit]
    slots[.animal] = [.🐱, .🐶, .🐭]
    slots[.fruit] = [.🍎]
    XCTAssertEqual(Array(slots), [.🐱, .🍎])

    slots.patterns = [.animal, .fruit, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭, .🐹, .🐰, .🐵, .🐼]
    slots[.fruit] = [.🍎, .🍌, .🍇, .🍉, .🍑, .🍍]
    XCTAssertEqual(Array(slots), [
      .🐶, .🍎, .🍌,
      .🐱, .🍇, .🍉,
      .🐭, .🍑, .🍍,
      .🐹
    ])
  }

  func testHeaders() {
    slots.headers = [.food]
    slots.patterns = [.animal, .fruit, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.food] = [.🍗, .🍔, .🌭, .🍕, .🍦]
    XCTAssertEqual(Array(slots), [.🍗, .🍔, .🌭, .🍕, .🍦, .🐶])

    slots.headers = [.animal, .fruit, .food]
    slots.patterns = [.food]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.fruit] = [.🍎, .🍌, .🍇]
    slots[.food] = [.🍗, .🍔, .🌭, .🍕, .🍦]
    XCTAssertEqual(Array(slots), [.🐶, .🍎, .🍗, .🐱, .🍌, .🍔, .🐭, .🍇, .🌭, .🍕, .🍦])
  }

  func testPlaceholder() {
    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭, .🐹]
    slots[.fruit] = [.🍎]
    slots.pleaceholder = .animal
    XCTAssertEqual(Array(slots), [.🐶, .🍎, .🐱, .🐭, .🐹])

    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭, .🐹]
    slots[.fruit] = [.🍎]
    slots[.food] = [.🍗, .🍔, .🌭, .🍕, .🍦]
    slots.pleaceholder = .food
    XCTAssertEqual(Array(slots), [.🐶, .🍎, .🐱, .🍗, .🍔, .🌭, .🍕, .🍦])
  }

  func testFixtures() {
    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.fruit] = [.🍎, .🍌, .🍇]
    slots[.food] = [.🍗, .🍔, .🌭]
    slots.fixtures = [
      0: .food,
    ]
    XCTAssertEqual(Array(slots), [
      .🍗,
      .🐶, .🍎,
      .🐱, .🍌,
      .🐭, .🍇,
    ])

    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.fruit] = [.🍎, .🍌, .🍇]
    slots[.food] = [.🍗, .🍔, .🌭]
    slots.fixtures = [
      1: .food,
    ]
    XCTAssertEqual(Array(slots), [
      .🐶, .🍗, .🍎,
      .🐱, .🍌,
      .🐭, .🍇,
    ])

    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.fruit] = [.🍎, .🍌, .🍇]
    slots[.food] = [.🍗, .🍔, .🌭]
    slots.fixtures = [
      0: .food,
      3: .food,
    ]
    XCTAssertEqual(Array(slots), [
      .🍗, .🐶, .🍎,
      .🍔, .🐱, .🍌,
      .🐭, .🍇,
    ])

    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.fruit] = [.🍎, .🍌, .🍇]
    slots[.food] = [.🍗, .🍔, .🌭]
    slots.fixtures = [
      1: .food,
      2: .food,
    ]
    XCTAssertEqual(Array(slots), [.🐶, .🍗, .🍔, .🍎, .🐱, .🍌, .🐭, .🍇])

    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱, .🐭]
    slots[.fruit] = [.🍎, .🍌, .🍇]
    slots[.food] = [.🍗, .🍔, .🌭]
    slots.fixtures = [
      1: .animal,
      3: .food,
    ]
    XCTAssertEqual(Array(slots), [.🐶, .🐱, .🍎, .🍗, .🐭, .🍌])

    slots.patterns = [.animal, .fruit]
    slots[.animal] = [.🐶, .🐱]
    slots[.fruit] = [.🍎, .🍌]
    slots[.food] = [.🍗, .🍔]
    slots.fixtures = [
      10: .food,
    ]
    XCTAssertEqual(Array(slots), [.🐶, .🍎, .🐱, .🍌])
  }

}
