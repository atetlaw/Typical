# Typical

Typical is a Swift micro-framework for wrapping the closure `(Subject) -> Bool` into a composable form.

## Introduction

A closure with the form `(Subject) -> Bool` is very useful for matching purposes, where `Subject` is the type you want to test. Typical is a protocol that adds operators and `Collection` methods so you can join multiple closures together, with custom matching logic, and create a single instance that is also in the form of `(Subject) -> Bool`.

```swift
public protocol Typical {
    associatedtype Subject
    func test(_ subject: Subject) -> Bool
    init(_ predicate: @escaping (Subject) -> Bool)
}
```

## Example

If you want to match instances of `Int` with several test conditions that you can define in the form of `(Int) -> Bool`:

```swift
{ $0 == 8 }
{ $0 > 5 }
{ $0 < 15 }
```

First create a type that can store the closure in a variable and implement `Typical`:

```swift
struct TypicalInt: Typical {
    typealias Subject = Int
    private var closure: (Int) -> Bool
    init(_ test: @escaping (Int) -> Bool) {
        closure = test
    }
    func test(_ s: Int) -> Bool {
        return closure(s)
    }
}
```

Now you can create 3 instances of your struct:

```swift
let isEqualTo8 = TypicalInt { $0 == 8 }
let isGreaterThan5 = TypicalInt { $0 > 5 }
let isLessThan15 = TypicalInt { $0 < 15 }
```

Since the struct implements `Typical` we can join them all together to make 1 struct that combines the logic of all the matches. Here we match the int if it's greater than `5`, less than `15`, but not equal to `8`:

```swift
let selectTheRightInt = isGreaterThan5 && isLessThan15 && !isEqualTo8
```

Now we can test integers by using `selectTheRightInt.test(6)` (returns true). Which is handy if you have an array of `Int` values:

```swift
let ints = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
ints.filter(selectTheRightInt.test)
```

This will return `[6,7,9,10,11,12,13,14]`.

The framework also has a handy class, to make implementing `Typical` easy:

```swift
public final class Matching<T>: Typical {
    public typealias Subject = T
    private var predicate: (T) -> Bool
    public init(_ test: @escaping (T) -> Bool) {
        predicate = test
    }
    public func test(_ s: T) -> Bool {
        return predicate(s)
    }
}
```

So instead of my custom struct I could have just used: 

```swift
typealias TypicalInt = Matching<Int>
```

Typical includes the `&&`, `||`, and `!` operators, as well as a `withAll` and `withAny` property on collections of Typical instances. There are also static methods `withAll` and `withAny` that take a variable list of `Typical` instances, as well as a `pick` method for ternary operator-style logic. 

## Why?

It came about because I wanted to have reusable matching logic in unit tests. I was testing instances of `URLRequest` and created a bunch of operators to test the hostname, scheme, path, querystring etc. I've inlcuded some examples in the unit tests.

It was also bit of fun, since I was trying to learn Swift generics. I also think Swift micro-frameworks are pretty cool, and I wanted to write one! In reality it's a silly little protocol with limited functionalty, but who knows, someone else might find it useful too.

