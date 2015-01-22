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

class SlotsTests: XCTestCase {

    var slots: Slots!

    override func setUp() {
        super.setUp()
        self.slots = Slots()
    }

    func testCount() {
        self.slots.pattern = []
        self.slots["odd"] = [1, 3]
        XCTAssertEqual(self.slots.count, 0)

        self.slots.pattern = ["even", "even", "odd"]
        self.slots["even"] = [2, 4, 6, 8]
        self.slots["odd"] = [1, 3]
        XCTAssertEqual(self.slots.count, 6)

        self.slots.pattern = ["even", "even", "odd"]
        self.slots["even"] = [2, 4]
        self.slots["odd"] = [1, 3, 5]
        XCTAssertEqual(self.slots.count, 3)

        self.slots.pattern = ["mod-0", "mod-1", "mod-2"]
        self.slots["mod-0"] = [0, 3, 6, 9]
        self.slots["mod-1"] = [1]
        self.slots["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.slots.count, 4)

        self.slots.pattern = ["mod-0", "mod-1", "mod-1", "mod-2"]
        self.slots["mod-0"] = [0, 3, 6, 9]
        self.slots["mod-1"] = [1, 4, 7, 10, 13]
        self.slots["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.slots.count, 10)
    }

    func testSubscriptionIndex() {
        var expected: [Int]

        self.slots.pattern = ["even", "even", "odd"]
        self.slots["even"] = [2, 4, 6, 8]
        self.slots["odd"] = [1, 3]
        expected = [2, 4, 1, 6, 8, 3]
        for i in 0..<self.slots.count {
            XCTAssertEqual(self.slots[i] as Int, expected[i])
        }
        XCTAssertNil(self.slots[6])

        self.slots.pattern = ["mod-0", "mod-1", "mod-2"]
        self.slots["mod-0"] = [0, 3, 6, 9]
        self.slots["mod-1"] = [1]
        self.slots["mod-2"] = [2, 5, 8]
        expected = [0, 1, 2, 3]
        for i in 0..<self.slots.count {
            XCTAssertEqual(self.slots[i] as Int, expected[i])
        }

        self.slots.pattern = ["mod-0", "mod-1", "mod-1", "mod-2"]
        self.slots["mod-0"] = [0, 3, 6, 9]
        self.slots["mod-1"] = [1, 4, 7, 10, 13]
        self.slots["mod-2"] = [2, 5, 8]
        expected = [0, 1, 4, 2, 3, 7, 10, 5, 6, 13]
        for i in 0..<self.slots.count {
            XCTAssertEqual(self.slots[i] as Int, expected[i])
        }
    }

    func testRepeatable() {
        self.slots.pattern = ["even", "even", "odd"]
        self.slots.repeatables = []
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3]
        XCTAssertEqual(self.slots.count, 8)
        XCTAssertEqual(self.slots.contents as [Int], [2, 4, 1, 6, 8, 3, 10, 12])

        self.slots.pattern = ["even", "even", "odd"]
        self.slots.repeatables = ["even"]
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3]
        XCTAssertEqual(self.slots.count, 10)

        self.slots.pattern = ["mod-0", "mod-1", "mod-2"]
        self.slots.repeatables = ["mod-0"]
        self.slots["mod-0"] = [0, 3, 6, 9, 12, 15]
        self.slots["mod-1"] = [1, 4]
        self.slots["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.slots.count, 10)

        self.slots.pattern = ["mod-0", "mod-1", "mod-2"]
        self.slots.repeatables = ["mod-0", "mod-2"]
        self.slots["mod-0"] = [0, 3, 6, 9, 12, 15]
        self.slots["mod-1"] = [1, 4]
        self.slots["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.slots.count, 11)
    }

    func testSubscriptionKey() {
        let evens = [2, 4, 6, 8]
        let odds = [1, 3, 5]
        self.slots["even"] = evens
        self.slots["odd"] = odds
        XCTAssertEqual(evens, self.slots["even"] as [Int])
        XCTAssertEqual(odds, self.slots["odd"] as [Int])
    }

    func testHeader() {
        self.slots.header = ["even", "even", "even"]
        self.slots.pattern = ["even", "odd"]
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3, 5]
        let expected = [2, 4, 6, 8, 1, 10, 3, 12, 5, 14]
        for i in 0..<self.slots.count {
            XCTAssertEqual(self.slots[i] as Int, expected[i])
        }
    }

    func testHeaderEmpty() {
        self.slots.header = []
        self.slots.pattern = ["even", "odd"]
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3, 5]
        let expected = [2, 1, 4, 3, 6, 5, 8]
        for i in 0..<self.slots.count {
            XCTAssertEqual(self.slots[i] as Int, expected[i])
        }
    }

    func testTypeAtIndex() {
        self.slots.pattern = ["even", "odd"]
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3, 5]
        XCTAssertEqual(self.slots.typeAtIndex(2)!, "even")
    }

    func testTypeAtIndexHeader() {
        self.slots.header = ["odd"]
        self.slots.pattern = ["even", "odd"]
        self.slots.repeatables = ["even"]
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3, 5]
        XCTAssertEqual(self.slots.typeAtIndex(0)!, "odd")
    }

    func testTypeAtIndexRepeatable() {
        self.slots.pattern = ["even", "odd"]
        self.slots.repeatables = ["even"]
        self.slots["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.slots["odd"] = [1, 3, 5]
        XCTAssertEqual(self.slots.typeAtIndex(7)!, "even")
    }

    func testTypeAtIndexNil() {
        self.slots.pattern = ["even", "odd"]
        self.slots["even"] = [2, 4, 6]
        self.slots["odd"] = [1, 3, 5]
        XCTAssert(self.slots.typeAtIndex(6) == nil)
    }

}