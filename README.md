Bucket
======

[![Build Status](https://travis-ci.org/devxoul/Bucket.svg)](https://travis-ci.org/devxoul/Bucket)
[![CocoaPods](http://img.shields.io/cocoapods/v/SwiftyColor.svg?style=flat)](http://cocoapods.org/?q=name%3ABucket%20author%3Adevxoul)

Dynamic contents management for Swift.


Installation
------------

### CocoaPods

**requirements:**

- iOS >= 8.0
- OS X >= 10.9
- CocoaPods 0.36.0.beta.1

**Podfile**

```ruby
pod 'Bucket', '0.1.0'
```


### Git Submodule

```shell
git submodule add https://github.com/devxoul/Bucket.git
git submodule update --remote
```

Then add source code files from Bucket directory into your Xcode project.


Getting Started
---------------

### Storing Contents

Bucket can store all kind of contents. Each type of contents must be an unique string value.

This code below describes a basic example for storing some alphabet letters and numbers:

```swift
let bucket = Bucket()
bucket["alphabet"] = ["a", "b", "c"]
bucket["number"] = [1, 2, 3, 4, 5]
```


### Setting Pattern

Bucket can sort stored contents according to specified pattern. You can assign array of content types to `pattern` property to specify contents pattern.

For example, when contents pattern is set to `["alphabet", "number"]`, Bucket will sort contents of `"alphabet"` and those of `"number"` to be alternated with each other.

```swift
bucket.pattern = ["alphabet", "number"]
bucket["alphabet"] = ["a", "b", "c"]
bucket["number"] = [1, 2, 3, 4, 5]
bucket.contents // ["a", 1, "b", 2, "c", 3]
```

Although there are 5 objects in `"alphabet"`, but `bucket.contents` returns array that contains only 3 numbers because there is no more objects in `"alphabet"` after 3 time alternated. You can check the number of elements in sorted contents with `count` property.

```swift
bucket.count // 6
```

Same content type can appear more than one time.

```swift
bucket.pattern = ["alphabet", "number", "number"]
bucket.contents // ["a", 1, 2, "b", 3, 4, "c", 5]
```


### Repeatables

You can assign repeatable content types to `repeatables` property. Content types specified in `repeatables` will be repeated until the contents are all exhausted.

```swift
bucket.pattern = ["alphabet", "number"]
bucket.repeatables = ["number"] // make repeatable
bucket["alphabet"] = ["a", "b", "c"]
bucket["number"] = [1, 2, 3, 4, 5]
bucket.contents // ["a", 1, "b", 2, "c", 3, 4, 5]
```


### Getting Contents

Bucket provides the easy way to get contents. Let's assume that the bucket declared like this:

```swift
bucket.pattern = ["alphabet", "number", "number"]
bucket["alphabet"] = ["a", "b", "c"]
bucket["number"] = [1, 2, 3, 4, 5]
```

Then we can get 7th content in the bucket with subscription, like an array.

```swift
bucket[6] // "c"
```

If we attempt to get value of non-existing index, it'll return `nil`.

```swift
bucket[6] // "c"
bucket[7] // 5
bucket[8] // nil
```

We can get `Slice` with subrange.

```swift
bucket[0..<4] // "a", 1, 2, "b"
```


### Real-World Example

Let's apply Bucket to real world situation. Assume that we have to make a newsfeed like [StyleShare](https://stylesha.re)'s stylefeed. There are many content types in a feed, such as: style, featured user, featured collection, advertisements, etc.

```swift
// declare content types as constant
struct ContentType {
    static let Style = "Style"
    static let Advertisement = "Advertisement"
}

func viewDidLoad() {
    super.viewDidLoad()

    // each advertisements appear after 3 styles
    self.bucket.pattern = [
        ContentType.Style, ContentType.Style, ContentType.Style
        ContentType.Advertisement
    ]
    
    // styles must be repeated even if there's no advertisements.
    self.bucket.repeatables = [ContentType.Style]
}

func fetchStyles() {
    self.bucket[ContentType.Style] = // styles from API response
    self.tableView.reloadData()
}

func fetchAdvertisements() {
    self.bucket[ContentType.Advertisement] = // advertisements from API response
    self.tableView.reloadData()
}

func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.bucket.count
}

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let contentType = self.bucket.typeAtIndex(indexPath.row)
    let content = self.buckets.content[indexPath.row]
    
    switch contentType {
        case ContentType.Style:
            let cell = // ...
            cell.style = content as Style
            return cell

        case ContentType.Advertisement:
            let cell = // ...
            cell.advertisement = content as Advertisement
            return cell
    }
}
```
