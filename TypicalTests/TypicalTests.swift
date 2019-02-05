//
//  TypicalTests.swift
//  TypicalTests
//
//  Created by Andrew Tetlaw on 7/1/17.
//
//

import XCTest
@testable import Typical

typealias TypicalURL = Matching<URLComponents>

struct TypicalInt: Typical {
    typealias Subject = Int
    private var predicate: (Int) -> Bool
    init(_ test: @escaping (Int) -> Bool) {
        predicate = test
    }
    func test(_ s: Int) -> Bool {
        return predicate(s)
    }
}

class TypicalTests: XCTestCase {

    lazy var subject: URLComponents = {
        var c = URLComponents()
        c.host = "example.com"
        c.scheme = "http"
        c.path = "go/here"
        return c
    }()

    func testSimpleMatching() {
        let hostCheck = TypicalURL { $0.host == "example.com" }
        XCTAssertTrue(hostCheck.test(subject))
    }

    func testCombinedMatching() {
        let check1 = TypicalURL { $0.host == "example.com" }
        let check2 = TypicalURL { $0.scheme == "http" }
        let check3 = TypicalURL { $0.path == "go/here" }
        let combined = check1 && check2 && check3
        XCTAssertTrue(combined.test(subject))
    }

    func testCombinedMatchingAllOrAny() {
        let check1 = TypicalURL { $0.host == "example.com" }
        let check2 = TypicalURL { $0.scheme == "https" }
        let check3 = TypicalURL { $0.path == "go/here" }
        let allChecks = TypicalURL.withAll(check1, check2, check3)
        let anyChecks = TypicalURL.withAny(check1, check2, check3)
        XCTAssertFalse(allChecks.test(subject))
        XCTAssertTrue(anyChecks.test(subject))
    }

    func testCombinedMatchingAllOrAnyWithCustomOperators() {
        let check1 = TypicalURL { $0.host == "example.com" }
        let check2 = TypicalURL { $0.scheme == "https" }
        let check3 = TypicalURL { $0.path == "go/here" }
        let allChecks = check1 && check2 && check3
        let anyChecks = check1 || check2 || check3
        XCTAssertFalse(allChecks.test(subject))
        XCTAssertTrue(anyChecks.test(subject))
    }

    func testArrayOperations() {
        typealias MatchingInt = Matching<Int>

        let ints = [1,2,3,4,5,6,7,8,9,0]
        let expected = [4,5,6,7]
        let is3 = MatchingInt { $0 == 3 }
        let isgt3 = MatchingInt { $0 > 3 }
        let islt8 = MatchingInt { $0 < 8 }

        let select = isgt3 && islt8 && !is3

        XCTAssertEqual(ints.filter(select.test), expected)
        XCTAssertEqual(ints.first(where: select.test), 4)
    }

    func testArrayOperationsWithCustomStruct() {

        let ints = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
        let expected = [6,7,9,10,11,12,13,14]
        let isEqualTo8 = TypicalInt { $0 == 8 }
        let isGreaterThan5 = TypicalInt { $0 > 5 }
        let isLessThan15 = TypicalInt { $0 < 15 }

        let select = isGreaterThan5 && isLessThan15 && !isEqualTo8

        XCTAssertEqual(ints.filter(select.test), expected)
        XCTAssertEqual(ints.first(where: select.test), 6)
    }

    func testComplexCombinedMatching() {
        let example = TypicalURL { $0.host == "example.com" }
        let zebra = TypicalURL { $0.host == "zebra.com" }
        let github = TypicalURL { $0.host == "github.com" }

        let http = TypicalURL { $0.scheme == "http" }
        let https = TypicalURL { $0.scheme == "https" }
        let file = TypicalURL { $0.scheme == "file" }

        let path1 = TypicalURL { $0.path == "go/here" }
        let path2 = TypicalURL { $0.path == "go/there" }
        let path3 = TypicalURL { $0.path == "go/nowhere" }

        let anyHTTP = (http || https) && !file
        let anyHost = TypicalURL.withAny(example, zebra, github)
        let anyPath = TypicalURL.withAny(path1, path2, path3)

        let allofit = TypicalURL.withAll(anyHost, anyHTTP, anyPath)

        XCTAssertTrue(example.test(subject))
        XCTAssertTrue(anyHTTP.test(subject))
        XCTAssertFalse(!example.test(subject))
        XCTAssertTrue(allofit.test(subject))
    }

    func testPickFunction() {
        let s1 = subject
        let s2: URLComponents = {
            var c = URLComponents()
            c.host = "example.com"
            c.scheme = "https"
            c.path = "go/elsewhere"
            return c
        }()

        let example = TypicalURL { $0.host == "example.com" }
        let http = TypicalURL { $0.scheme == "http" }
        let path = TypicalURL { $0.path == "go/here" }

        let picker = TypicalURL.pick(when: http, then: example, else: path)
        XCTAssertTrue(picker.test(s1))
        XCTAssertFalse(picker.test(s2))
        
    }
}
