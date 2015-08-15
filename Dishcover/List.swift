import Foundation


/// Abstract functional list type
///
/// Concrete types are EmptyList<T> and Cons<T>
public class List<T>: SequenceType {

    /// Return true if this is an empty list, false if not
    public var isEmpty: Bool { return true }

    /// Return first element of list
    ///
    /// It is only legal to use this if isEmpty is false
    public var head: T! {
        assert(false, "cannot get head of an empty list")
        return nil
    }

    /// Return list of all elements except the first
    ///
    /// It is only legal to use this if isEmpty is false
    public var tail: List<T>! {
        assert(false, "cannot get tail of an empty list")
        return self
    }

    /// Return sequence generator
    public func generate() -> ListGenerator<T> {
        return ListGenerator(self)
    }

    /// Return number of elements
    public var count: Int {
        return List.countList(self, 0)
    }

    /// Return list of elements in reverse order
    public func reverse() -> List<T> {
        return List.reverseList(self, EmptyList())
    }

    // Private function used by count
    //
    // (It would be preferable to have this function nested within the
    // count getter body, but attempts to do so led to errors.)
    private class func countList(list: List<T>, _ count: Int) -> Int {
        if list.isEmpty { return count }
        else            { return countList(list.tail, count + 1) }
    }

    // Private function used by reverse()
    //
    // (It would be preferable to have this function nested within the
    // reverse() method body, but attempts to do so led to errors.)
    private class func reverseList(list: List<T>, _ result: List<T>) -> List<T> {
        if list.isEmpty { return result }
        else            { return reverseList(list.tail, Cons(list.head, result)) }
    }

    // No-arg constructor is private for abstract class.
    // Use EmptyList<T> or Cons<T>.
    private init() {}
}

/// Sequence generator for List<T>
public struct ListGenerator<T>: GeneratorType {
    private var list: List<T>

    public init(_ list: List<T>) {
        self.list = list
    }

    mutating public func next() -> T? {
        if list.isEmpty {
            return nil
        }
        else {
            let head = list.head
            list = list.tail
            return head
        }
    }
}

extension List: Printable {

    public var description: String {
        if isEmpty {
            return "nil"
        }
        else {
            return "\(head), \(tail.description)"
        }
    }
}

/// Empty list
public final class EmptyList<T>: List<T> {

    /// Initializer
    public override init() {}
}


/// List constructor
public final class Cons<T>: List<T> {
    private let _head: T!
    private let _tail: List<T>!

    /// Initializer
    public init(_ head: T, _ tail: List<T>) {
        _head = head
        _tail = tail
    }

    override public var isEmpty: Bool { return false }

    override public var head: T       { return _head }

    override public var tail: List<T> { return _tail }
}


/// Create List<T> from a sequence of values
public func list<S: SequenceType>(s: S) -> List<S.Generator.Element> {
    return list(s.generate())
}

/// Create List<T> from a sequence generator
public func list<G: GeneratorType>(var g: G) -> List<G.Element> {
    let firstElement = g.next()
    if let head = firstElement {
        let tail = list(g)
        return Cons(head, tail)
    }
    else {
        return EmptyList()
    }
}


// Examples

let intList = Cons(1, Cons(2, Cons(3, Cons(4, EmptyList()))))
intList.description                                      // "1, 2, 3, 4, nil"
let intArray = Array<Int>(intList)                       // [1, 2, 3, 4]

for i in intList {
    println("\(i)")                                      // "1\n2\n3\n4\n"
}

let stringList = list(["One", "Two", "Three"])
stringList.description                                   // "One, Two, Three, nil"
stringList.count                                         // 3
stringList.reverse().description                         // "Three, Two, One, nil"
