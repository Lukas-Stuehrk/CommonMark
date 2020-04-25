import cmark

private struct Children: Sequence {
    var cmark_node: OpaquePointer

    init(of node: Node) {
        cmark_node = node.cmark_node
    }

    func makeIterator() -> AnyIterator<Node> {
        var iterator = CMarkNodeChildIterator(cmark_node)
        return AnyIterator {
            guard let child = iterator.next() else { return nil }
            return Node.create(for: child)
        }
    }
}

private struct CMarkNodeChildIterator: IteratorProtocol {
    var current: OpaquePointer!

    init(_ node: OpaquePointer!) {
        current = cmark_node_first_child(node)
    }

    mutating func next() -> OpaquePointer? {
        guard let next = current else { return nil }
        defer { current = cmark_node_next(current) }
        return next
    }
}

// MARK: -

fileprivate func add<Child: Node>(_ child: Child, with operation: () -> Int32) -> Bool {
    let status = operation()
    switch status {
    case 1:
        child.managed = false
        return true
    case 0:
        return false
    default:
        assertionFailure("unexpected status code: \(status)")
        return false
    }
}

// MARK: -

public protocol Container: Node {
    associatedtype ChildNode
}

extension Container where ChildNode: Node {
    /// The block's children.
    public var children: [ChildNode] {
        get {
            let children: [Node] = Array(Children(of: self))
            return children as? [ChildNode] ?? []
        }

        set {
            for child in children {
                remove(child: child)
            }

            for child in newValue {
                append(child: child)
            }
        }
    }

    /**
     Adds a block to the beginning of the block's children.

     - Parameters:
        - child: The block to add.
     - Returns: `true` if successful, otherwise `false`.
     */
    @discardableResult
    public func prepend(child: ChildNode) -> Bool {
        return add(child) { cmark_node_prepend_child(cmark_node, child.cmark_node) }
    }

    /**
     Adds a block to the end of the block's children.

     - Parameters:
        - child: The block to add.
     - Returns: `true` if successful, otherwise `false`.
    */
    @discardableResult
    public func append(child: ChildNode) -> Bool {
        return add(child) { cmark_node_append_child(cmark_node, child.cmark_node) }
    }

    /**
     Inserts a block to the block's children before a specified sibling.

     - Parameters:
        - child: The block to add.
        - sibling: The child before which the block is added
     - Returns: `true` if successful, otherwise `false`.
    */
    @discardableResult
    public func insert(child: ChildNode, before sibling: ChildNode) -> Bool {
        return add(child) { cmark_node_insert_before(sibling.cmark_node, child.cmark_node) }
    }

    /**
     Inserts a block to the block's children after a specified sibling.

     - Parameters:
        - child: The block to add.
        - sibling: The child after which the block is added
     - Returns: `true` if successful, otherwise `false`.
    */
    @discardableResult
    public func insert(child: ChildNode, after sibling: ChildNode) -> Bool {
        return add(child) { cmark_node_insert_after(sibling.cmark_node, child.cmark_node) }
    }

    /**
     Removes a block from the block's children.

     - Parameters:
        - child: The block to remove.
     - Returns: `true` if successful, otherwise `false`.
     */
    @discardableResult
    public func remove(child: ChildNode) -> Bool {
        guard child.parent == self else { return false }
        cmark_node_unlink(child.cmark_node)
        child.managed = true
        return true
    }
}


// MARK: -

public protocol ContainerOfBlocks {}
extension ContainerOfBlocks {
    public typealias ChildNode = Block & Node
}

extension Document: Container, ContainerOfBlocks {}
extension BlockQuote: Container, ContainerOfBlocks {}

// MARK: -

public protocol ContainerOfInlineElements {}
extension ContainerOfInlineElements {
    public typealias ChildNode = Inline & Node
}

extension Heading: Container, ContainerOfInlineElements {}
extension Paragraph: Container, ContainerOfInlineElements {}
extension HTMLBlock: Container, ContainerOfInlineElements {}
extension CodeBlock: Container, ContainerOfInlineElements {}
extension ThematicBreak: Container, ContainerOfInlineElements {}
extension Strong: Container, ContainerOfInlineElements {}
extension Emphasis: Container, ContainerOfInlineElements {}
extension Link: Container, ContainerOfInlineElements {}

// MARK: -

extension List: Container {
    public typealias ChildNode = Item
}

// MARK: -

extension List.Item: Container {
    public typealias ChildNode = Node
}
