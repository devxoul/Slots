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

/// A protocol which defines a slot type.
public protocol SlotType: Hashable {
  associatedtype Item
}

public struct Slots<T: SlotType>: Sequence {
  public typealias Slot = T
  public typealias Item = T.Item

  public var headers: [Slot]?
  public var patterns: [Slot]?

  /// This slot will be used after `headers` and `patterns` are exhausted.
  public var pleaceholder: Slot?

  /// Fixes slot in specific position.
  ///
  ///   slots.fixtures = [
  ///     0: MySlot.banner,
  ///     3: MySlot.news,
  ///   ]
  public var fixtures: [Int: Slot]?

  /// Returns all slots items which is set from subscript.
  private var allSlotItems: [Slot: [Item]] = [:]

  /// Returns a stack which represents non-yet-generated slot items.
  fileprivate var slotItemStack: [Slot: [Item]] = [:]

  /// Returns a generated items.
  fileprivate var generatedItems: [Item] = []

  /// Returns a number of generated headers.
  fileprivate var generatedHeadersCount: Int = 0

  /// Returns a number of generated fixtures.
  fileprivate var generatedFixturesCount: Int = 0

  /// This indicates that the non-placeholder items are exhausted. If `true`, `next()` will
  /// generate from `placeholder`.
  fileprivate var isNonplaceholderExhausted: Bool = false

  public init(patterns: [Slot]? = nil) {
    self.patterns = patterns
  }

  public subscript(slot: Slot) -> [Item]? {
    get {
      return self.allSlotItems[slot]
    }
    set {
      self.allSlotItems[slot] = newValue
      self.slotItemStack[slot] = newValue
    }
  }
}

extension Slots: IteratorProtocol {
  public mutating func next() -> Item? {
    // fixtures
    let nextFixtureIndex = self.generatedItems.count
    if let slot = self.fixtures?[nextFixtureIndex], let item = self.next(for: slot) {
      self.generatedFixturesCount += 1
      return item
    }

    // headers
    let nextHeaderIndex = nextFixtureIndex - self.generatedFixturesCount
    if !self.isNonplaceholderExhausted,
      let item = self.next(at: nextHeaderIndex, from: self.headers) {
      self.generatedHeadersCount += 1
      return item
    }

    // patterns
    let nextPatternIndex = nextHeaderIndex - self.generatedHeadersCount
    if !self.isNonplaceholderExhausted,
      let item = self.next(at: nextPatternIndex, from: self.patterns) {
      return item
    }

    // placeholder
    self.isNonplaceholderExhausted = true
    if let placeholder = self.pleaceholder, let item = self.next(for: placeholder) {
      return item
    }

    return nil
  }

  private mutating func next(at index: Int, from slots: [Slot]?) -> Item? {
    guard let slots = slots, !slots.isEmpty else { return nil }
    guard slots.indices.contains(index % slots.count) else { return nil }
    return self.next(for: slots[index % slots.count])
  }

  private mutating func next(for slot: Slot) -> Item? {
    guard let items = self.slotItemStack[slot], let item = items.first else { return nil }
    self.slotItemStack[slot] = Array(items.dropFirst())
    self.generatedItems.append(item)
    return item
  }
}
