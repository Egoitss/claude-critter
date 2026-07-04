# Testing harness adaptation (read before any task's tests)

This environment has Command Line Tools only — **no XCTest, no
swift-testing, `swift test` does not run.** Tests run as a plain executable
via `SHAFTTestKit` + the `SHAFTTests` target. Each task's brief shows tests
in XCTest style; realize them under this harness as follows.

## Where tests live

- Put each suite in `Sources/SHAFTTests/<Suite>.swift` (NOT `Tests/`).
- Start the file with `import SHAFTCore` and `import SHAFTTestKit`
  (no `@testable` — all SHAFTCore types under test are `public`).

## Convert a brief's XCTest class to one run function

The brief writes `final class FooTests: XCTestCase { func testA() {…}
func testB() {…} }`. Realize it as a single free function whose body is the
methods' bodies concatenated in order:

```swift
func runFooTests() {
    // body of testA (verbatim asserts from the brief)
    // body of testB
}
```

Keep any helper types the brief defines (e.g. `FakeRunner`, `FakeHTTP`,
`FakeToken`) as top-level types in the same file. The assert calls
themselves are copied **verbatim** — the harness provides XCTest-named
functions.

## Register the suite

Add one call to `Sources/SHAFTTests/main.swift`, above `xctReport()`:

```swift
runFooTests()
```

For an async suite, make it `func runFooTests() async` and register it as
`await runFooTests()` (top-level `await` is allowed in `main.swift`).

## Assert functions available (XCTest-named, in SHAFTTestKit)

- `XCTAssertTrue(_:_ msg:)`, `XCTAssertFalse(_:_ msg:)`
- `XCTAssertEqual(_:_:_ msg:)` (generic `Equatable?`)
- `XCTAssertEqual(_:_:accuracy:_ msg:)` (optional-friendly `Double`)
- `XCTAssertNotEqual(_:_:_ msg:)`
- `XCTAssertNil(_:_ msg:)`
- `XCTAssertThrowsError(_:_ msg:)`

Each takes an optional trailing message string; pass a short label so a
failure is identifiable (the brief's asserts often omit it — add one).

## Run it

```bash
swift run SHAFTTests
```

- **RED** (before the production code exists): a compile error, or the
  final line shows `failures: N` with N > 0. Either is a valid failing
  state to observe first.
- **GREEN**: the final line reads `checks: <n>, failures: 0` and the exit
  code is 0. Do not check the exit code through a pipe (`| tail` reports
  the pipe's status, not the program's) — read the `failures:` line.

## Commit

Use the brief's commit message. Stage `Sources/SHAFTTests/<Suite>.swift`,
the edited `Sources/SHAFTTests/main.swift`, and the production files the
brief lists (paths under `Sources/SHAFTCore/`, not `Tests/`).
