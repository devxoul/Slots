//
// Bucket
//
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

class BucketTests: XCTestCase {

    var bucket: Bucket!

    override func setUp() {
        super.setUp()
        self.bucket = Bucket()
    }

    func testCount() {
        self.bucket.pattern = []
        self.bucket["odd"] = [1, 3]
        XCTAssertEqual(self.bucket.count, 0)

        self.bucket.pattern = ["even", "even", "odd"]
        self.bucket["even"] = [2, 4, 6, 8]
        self.bucket["odd"] = [1, 3]
        XCTAssertEqual(self.bucket.count, 6)

        self.bucket.pattern = ["even", "even", "odd"]
        self.bucket["even"] = [2, 4]
        self.bucket["odd"] = [1, 3, 5]
        XCTAssertEqual(self.bucket.count, 3)

        self.bucket.pattern = ["mod-0", "mod-1", "mod-2"]
        self.bucket["mod-0"] = [0, 3, 6, 9]
        self.bucket["mod-1"] = [1]
        self.bucket["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.bucket.count, 4)

        self.bucket.pattern = ["mod-0", "mod-1", "mod-1", "mod-2"]
        self.bucket["mod-0"] = [0, 3, 6, 9]
        self.bucket["mod-1"] = [1, 4, 7, 10, 13]
        self.bucket["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.bucket.count, 10)
    }

    func testSubscriptionIndex() {
        var expected: [Int]

        self.bucket.pattern = ["even", "even", "odd"]
        self.bucket["even"] = [2, 4, 6, 8]
        self.bucket["odd"] = [1, 3]
        expected = [2, 4, 1, 6, 8, 3]
        for i in 0..<self.bucket.count {
            XCTAssertEqual(self.bucket[i] as Int, expected[i])
        }
        XCTAssertNil(self.bucket[6])

        self.bucket.pattern = ["mod-0", "mod-1", "mod-2"]
        self.bucket["mod-0"] = [0, 3, 6, 9]
        self.bucket["mod-1"] = [1]
        self.bucket["mod-2"] = [2, 5, 8]
        expected = [0, 1, 2, 3]
        for i in 0..<self.bucket.count {
            XCTAssertEqual(self.bucket[i] as Int, expected[i])
        }

        self.bucket.pattern = ["mod-0", "mod-1", "mod-1", "mod-2"]
        self.bucket["mod-0"] = [0, 3, 6, 9]
        self.bucket["mod-1"] = [1, 4, 7, 10, 13]
        self.bucket["mod-2"] = [2, 5, 8]
        expected = [0, 1, 4, 2, 3, 7, 10, 5, 6, 13]
        for i in 0..<self.bucket.count {
            XCTAssertEqual(self.bucket[i] as Int, expected[i])
        }
    }

    func testRepeatable() {
        self.bucket.pattern = ["even", "even", "odd"]
        self.bucket.repeatables = []
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3]
        XCTAssertEqual(self.bucket.count, 8)
        XCTAssertEqual(self.bucket.contents as [Int], [2, 4, 1, 6, 8, 3, 10, 12])

        self.bucket.pattern = ["even", "even", "odd"]
        self.bucket.repeatables = ["even"]
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3]
        XCTAssertEqual(self.bucket.count, 10)

        self.bucket.pattern = ["mod-0", "mod-1", "mod-2"]
        self.bucket.repeatables = ["mod-0"]
        self.bucket["mod-0"] = [0, 3, 6, 9, 12, 15]
        self.bucket["mod-1"] = [1, 4]
        self.bucket["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.bucket.count, 10)

        self.bucket.pattern = ["mod-0", "mod-1", "mod-2"]
        self.bucket.repeatables = ["mod-0", "mod-2"]
        self.bucket["mod-0"] = [0, 3, 6, 9, 12, 15]
        self.bucket["mod-1"] = [1, 4]
        self.bucket["mod-2"] = [2, 5, 8]
        XCTAssertEqual(self.bucket.count, 11)
    }

    func testSubscriptionKey() {
        let evens = [2, 4, 6, 8]
        let odds = [1, 3, 5]
        self.bucket["even"] = evens
        self.bucket["odd"] = odds
        XCTAssertEqual(evens, self.bucket["even"] as [Int])
        XCTAssertEqual(odds, self.bucket["odd"] as [Int])
    }

    func testHeader() {
        self.bucket.header = ["even", "even", "even"]
        self.bucket.pattern = ["even", "odd"]
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3, 5]
        let expected = [2, 4, 6, 8, 1, 10, 3, 12, 5, 14]
        for i in 0..<self.bucket.count {
            XCTAssertEqual(self.bucket[i] as Int, expected[i])
        }
    }

    func testHeaderEmpty() {
        self.bucket.header = []
        self.bucket.pattern = ["even", "odd"]
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3, 5]
        let expected = [2, 1, 4, 3, 6, 5, 8]
        for i in 0..<self.bucket.count {
            XCTAssertEqual(self.bucket[i] as Int, expected[i])
        }
    }

    func testTypeAtIndex() {
        self.bucket.pattern = ["even", "odd"]
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3, 5]
        XCTAssertEqual(self.bucket.typeAtIndex(2)!, "even")
    }

    func testTypeAtIndexHeader() {
        self.bucket.header = ["odd"]
        self.bucket.pattern = ["even", "odd"]
        self.bucket.repeatables = ["even"]
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3, 5]
        XCTAssertEqual(self.bucket.typeAtIndex(0)!, "odd")
    }

    func testTypeAtIndexRepeatable() {
        self.bucket.pattern = ["even", "odd"]
        self.bucket.repeatables = ["even"]
        self.bucket["even"] = [2, 4, 6, 8, 10, 12, 14, 16]
        self.bucket["odd"] = [1, 3, 5]
        XCTAssertEqual(self.bucket.typeAtIndex(7)!, "even")
    }

    func testTypeAtIndexNil() {
        self.bucket.pattern = ["even", "odd"]
        self.bucket["even"] = [2, 4, 6]
        self.bucket["odd"] = [1, 3, 5]
        XCTAssert(self.bucket.typeAtIndex(6) == nil)
    }

}
