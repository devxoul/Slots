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

import Foundation

public class Slots {

    public var header: [String]? { didSet { self.setNeedsSort() } }
    public var pattern: [String]! { didSet { self.setNeedsSort() } }
    public var repeatables: [String]? { didSet { self.setNeedsSort() } }

    /// If content type is invalid or exhausted, Slots uses `defaultContentType` instead. `repeatables` will be ignored
    /// if `defaultContentType` is set.
    public var defaultContentType: String? { didSet { self.setNeedsSort() } }

    /// Fix content type in specific position. The pattern already exists in `pattern` would be ignored.
    ///
    /// Example::
    ///   slots.fixed = [
    ///     0: "SomeContentType",
    ///     3: "SomeContentType",
    ///   ]
    public var fixed: [Int: String]? { didSet { self.setNeedsSort() } }

    private var _patterns: [String]!

    private var _contentsForType: [String: [AnyObject]]!
    private var _contents: [AnyObject]!
    public var contents: [AnyObject] {
        self.sortIfNeeded()
        return self._contents
    }

    private var _needsSort: Bool = false
    public var needsSort: Bool {
        return self._needsSort
    }

    public var count: Int {
        self.sortIfNeeded()
        return self._contents.count
    }

    /// if set to `true`, subscript will return empty array(`[]`) instead of `nil` for undefined content types. Default
    /// value is `false`.
    ///
    /// Example::
    ///
    ///   slots["undefined"] // nil
    ///   slots.prefersEmptyArrayForUndefinedContentTypes = true
    ///   slots["undefined"] // []
    public var prefersEmptyArrayForUndefinedContentTypes = false


    // MARK: - Init

    public init() {
        self.pattern = []
        self._patterns = []
        self._contentsForType = [String: [AnyObject]]()
        self._contents = []
    }

    public convenience init(pattern: [String]) {
        self.init()
        self.pattern = pattern
    }


    // MARK: - Type At Index

    public func typeAtIndex(index: Int) -> String? {
        if index < 0 {
            return nil
        }
        self.sortIfNeeded()
        if index >= self._patterns.count {
            return nil
        }
        return self._patterns[index]
    }


    // MARK: - Subscripts

    public subscript(index: Int) -> AnyObject? {
        if index < 0 {
            return nil
        }
        self.sortIfNeeded()
        if index >= self._contents.count {
            return nil
        }
        return self._contents[index]
    }

    public subscript(subRange: Range<Int>) -> ArraySlice<AnyObject> {
        self.sortIfNeeded()
        return self._contents[subRange]
    }

    public subscript(type: String) -> [AnyObject]? {
        get {
            let contents = self._contentsForType[type]
            if self.prefersEmptyArrayForUndefinedContentTypes {
                return contents ?? []
            }
            return contents
        }
        set {
            self._contentsForType[type] = newValue
            self.setNeedsSort()
        }
    }


    // MARK: - Sort

    public func setNeedsSort() {
        self._needsSort = true
    }

    public func sortIfNeeded() {
        if self.needsSort {
            self.sort()
        }
    }

    public func sort() {
        self._needsSort = false
        self._patterns.removeAll()
        self._contents.removeAll()
        if self.pattern.count == 0 || self._contentsForType.count == 0 {
            return
        }

        var stacks = [String: [AnyObject]]()
        for (type, contents) in self._contentsForType {
            stacks[type] = reverse(contents)
        }

        var repeatableTypes = Set<String>()

        // if `defaultContentType` is set, `repeatables` will be ignored.
        if let repeatables = self.repeatables where self.defaultContentType == nil {
            repeatableTypes.intersect(Set(self.pattern))
            for type in self.pattern {
                if contains(repeatables, type) {
                    repeatableTypes.insert(type)
                }
            }
        }

        let enumerate = { (from: [String]) -> Bool in
            var nonRepeatableFinished = false
            for type in from {
                // no more data in stack
                if stacks[type] == nil || stacks[type]!.count == 0 {

                    // if `defaultContentType` exists, use it.
                    if let defaultType = self.defaultContentType,
                       var stack = stacks[defaultType] where stack.count > 0 {
                        let last: AnyObject = stacks[defaultType]!.removeLast()
                        self._patterns.append(defaultType)
                        self._contents.append(last)
                    }

                    // if `type` is repeatable, remove it from repeatables.
                    else {
                        if repeatableTypes.contains(type) {
                            repeatableTypes.remove(type)
                        } else {
                            nonRepeatableFinished = true
                        }
                        if repeatableTypes.count == 0 {
                            return true
                        }
                    }
                    continue
                }

                if !nonRepeatableFinished || repeatableTypes.contains(type) {
                    let last: AnyObject = stacks[type]!.removeLast()
                    self._patterns.append(type)
                    self._contents.append(last)
                }
            }
            return false
        }

        if let header = self.header {
            if enumerate(header) {
                return
            }
        }

        while true {
            if enumerate(self.pattern) {
                break
            }
        }

        if let fixed = self.fixed {
            for index in sorted(fixed.keys) {
                let type = fixed[index]!

                // ignore if the type already exists in `pattern`
                if contains(self.pattern, type) {
                    continue
                }

                if let content: AnyObject = stacks[type]?.last where contains(0...self._patterns.count, index) {
                    stacks[type]?.removeLast()
                    self._patterns.insert(type, atIndex: index)
                    self._contents.insert(content, atIndex: index)
                }
            }
        }
    }

}
