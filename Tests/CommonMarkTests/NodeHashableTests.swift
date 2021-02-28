import XCTest
import CommonMark

final class NodeHashableTests: XCTestCase {
    func testNodesEquality() {
        let firstNode = Paragraph(text: #"""
        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        and should act towards one another in a spirit of brotherhood.
        """#, replacingNewLinesWithBreaks: true)
        let secondNode = Paragraph(text: #"""
        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        and should act towards one another in a spirit of brotherhood.
        """#, replacingNewLinesWithBreaks: true)

        XCTAssertNotEqual(firstNode, secondNode)
        XCTAssertEqual(firstNode, firstNode)
        XCTAssertEqual(secondNode, secondNode)
    }

    func testNodesHashable() {
        let firstNode = Paragraph(text: #"""
        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        and should act towards one another in a spirit of brotherhood.
        """#, replacingNewLinesWithBreaks: true)
        let secondNode = Paragraph(text: #"""
        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        and should act towards one another in a spirit of brotherhood.
        """#, replacingNewLinesWithBreaks: true)

        var map = [Node: String]()
        map[firstNode] = "first"
        map[secondNode] = "second"

        XCTAssertEqual(map[firstNode], "first")
        XCTAssertEqual(map[secondNode], "second")
    }

    func testUpdatingValue() {
        let node = Text(literal: "Some Text")

        var map = [Node: String]()
        map[node] = "first mapping"
        map[node] = "second mapping"

        XCTAssertEqual(map[node], "second mapping")
    }
    
    func testNodesHashableWithManipulation() {
        let node = Paragraph(text: #"""
        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        """#, replacingNewLinesWithBreaks: true)
        var map = [Node: String]()
        map[node] = "exists"

        node.insert(child: Text(literal: "and should act towards one another in a spirit of brotherhood."), after: node.children[1])

        XCTAssertEqual(map[node], "exists")
    }
}
