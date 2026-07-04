import Foundation

// Minimal XCTest-compatible assertions so plan test bodies run unchanged
// under Command Line Tools (no XCTest). Each records a check; failures print
// to stderr and set a nonzero exit via xctReport().

public enum XCTState {
    public static var checks = 0
    public static var failures = 0
}

private func fail(_ msg: String, _ file: StaticString, _ line: UInt) {
    XCTState.failures += 1
    FileHandle.standardError.write(Data("✗ \(msg) [\(file):\(line)]\n".utf8))
}

public func XCTAssertTrue(_ c: Bool, _ m: String = "",
    file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    if !c { fail("expected true — \(m)", file, line) }
}

public func XCTAssertFalse(_ c: Bool, _ m: String = "",
    file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    if c { fail("expected false — \(m)", file, line) }
}

public func XCTAssertEqual<T: Equatable>(_ a: T?, _ b: T?, _ m: String = "",
    file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    if a != b {
        fail("\(desc(a)) != \(desc(b)) — \(m)", file, line)
    }
}

public func XCTAssertNotEqual<T: Equatable>(_ a: T?, _ b: T?, _ m: String = "",
    file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    if a == b { fail("unexpectedly equal — \(m)", file, line) }
}

// Optional-friendly accuracy overload (nil fails).
public func XCTAssertEqual(_ a: Double?, _ b: Double, accuracy: Double,
    _ m: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    guard let a = a, abs(a - b) <= accuracy else {
        fail("\(desc(a)) !~ \(b) — \(m)", file, line); return
    }
}

public func XCTAssertNil<T>(_ v: T?, _ m: String = "",
    file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    if v != nil { fail("expected nil — \(m)", file, line) }
}

public func XCTAssertThrowsError<T>(_ expr: @autoclosure () throws -> T,
    _ m: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTState.checks += 1
    do { _ = try expr(); fail("expected throw — \(m)", file, line) }
    catch {}
}

private func desc<T>(_ v: T?) -> String {
    v.map { "\($0)" } ?? "nil"
}

public func xctReport() -> Never {
    print("checks: \(XCTState.checks), failures: \(XCTState.failures)")
    exit(XCTState.failures == 0 ? 0 : 1)
}
