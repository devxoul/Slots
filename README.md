Slots
=====

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![Build Status](https://travis-ci.org/devxoul/Slots.svg)](https://travis-ci.org/devxoul/Slots)
[![CocoaPods](http://img.shields.io/cocoapods/v/Slots.svg?style=flat)](http://cocoapods.org/?q=name%3ASlots%20author%3Adevxoul)

Dynamic contents management for Swift.


At a Glance
-----------

```swift
let slots = Slots()
slots.pattern = ["Month", "Picture", "Picture", "Month", "Picture"]
slots["Month"] = ["Nov 2014", "Dec 2014", "Jan 2015"]
slots["Picture"] = [Picture(1), Picture(2), Picture(3)]
```

Then:

```swift
slots.contents // "Nov 2014", Picture(1), Picture(2), "Dec 2014", Picture(3), "Jan 2015"
slots[2] // Picture(2)
slots.type(at: 3) // "Month"
```


Installation
------------

- **For iOS 8+ projects** with [CocoaPods](https://cocoapods.org):

    ```ruby
    pod 'Slots'
    ```

- **For iOS 8+ projects** with [Carthage](https://github.com/Carthage/Carthage):

    ```
    github "devxoul/Slots" ~> 2.0
    ```

- **For iOS 7 projects** with [CocoaSeeds](https://github.com/devxoul/CocoaSeeds):

    ```ruby
    github 'devxoul/Then', '2.0.0', :files => 'Slots/*.swift'
    ```


Getting Started
---------------

### Storing Contents

Slots can store all kind of contents. Each type of contents must be an unique string value.

This code below describes a basic example for storing some alphabet letters and numbers:

```swift
let slots = Slots()
slots["alphabet"] = ["a", "b", "c"]
slots["number"] = [1, 2, 3, 4, 5]
```


### Using Pattern

Slots can sort stored contents according to specified pattern. You can assign array of content types to `pattern` property to specify contents pattern.

For example, when contents pattern is set to `["alphabet", "number"]`, Slots will sort contents of `"alphabet"` and those of `"number"` to be alternated with each other.

```swift
slots.pattern = ["alphabet", "number"]
slots["alphabet"] = ["a", "b", "c"]
slots["number"] = [1, 2, 3, 4, 5]
slots.contents // ["a", 1, "b", 2, "c", 3]
```

Although there are 5 objects in `"alphabet"`, but `slots.contents` returns array that contains only 3 numbers because there is no more objects in `"alphabet"` after 3 time alternated. You can check the number of elements in sorted contents with `count` property.

```swift
slots.count // 6
```

Same content type can appear more than once.

```swift
slots.pattern = ["alphabet", "number", "number"]
slots.contents // ["a", 1, 2, "b", 3, 4, "c", 5]
```


### Repeatables

You can assign repeatable content types to `repeatables` property. Content types specified in `repeatables` will be repeated until the contents are all exhausted.

```swift
slots.pattern = ["alphabet", "number"]
slots.repeatables = ["number"] // make repeatable
slots["alphabet"] = ["a", "b", "c"]
slots["number"] = [1, 2, 3, 4, 5]
slots.contents // ["a", 1, "b", 2, "c", 3, 4, 5]
```


### Getting Contents

Slots provides the easy way to get contents. Let's assume that the slots declared like this:

```swift
slots.pattern = ["alphabet", "number", "number"]
slots["alphabet"] = ["a", "b", "c"]
slots["number"] = [1, 2, 3, 4, 5]
```

Then we can get 7th content in the slots with subscription, like an array.

```swift
slots[6] // "c"
```

If we attempt to get value of non-existing index, it'll return `nil`.

```swift
slots[6] // "c"
slots[7] // 5
slots[8] // nil
```

We can get `Slice` with subrange.

```swift
slots[0..<4] // "a", 1, 2, "b"
```


### Real-World Example

Let's apply Slots to real world situation. Assume that we have to make a newsfeed like [StyleShare](https://stylesha.re)'s stylefeed. There are many content types in a feed, such as: style, featured user, featured collection, advertisements, etc.

```swift
// declare content types as constant
struct ContentType {
    static let style = "style"
    static let advertisement = "advertisement"
}

func viewDidLoad() {
    super.viewDidLoad()

    // each advertisements appear after 3 styles
    self.slots.pattern = [
        ContentType.style, ContentType.style, ContentType.style
        ContentType.advertisement
    ]
    
    // styles must be repeated even if there's no advertisements.
    self.slots.repeatables = [ContentType.style]
}

func fetchStyles() {
    self.slots[ContentType.style] = // styles from API response
    self.tableView.reloadData()
}

func fetchAdvertisements() {
    self.slots[ContentType.advertisement] = // advertisements from API response
    self.tableView.reloadData()
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.slots.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
    let contentType = self.slots.type(at: indexPath.row)
    let content = self.slots[indexPath.row]
    
    switch contentType {
        case ContentType.style:
            let cell = // ...
            cell.style = content as Style
            return cell

        case ContentType.advertisement:
            let cell = // ...
            cell.advertisement = content as Advertisement
            return cell
    }
}
```


License
-------

Slots is under MIT license. See the [LICENSE](LICENSE) file for more information.
