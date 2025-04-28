import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(DecoratableMacros)
import DecoratableMacros

let testMacros: [String: Macro.Type] = [
    "Decoratable": DecoratableMacro.self,
]
#endif

final class DecoratableTests: XCTestCase {
    func testEmptyProtocolWithDecoratable() throws {
        assertMacroExpansion(
            """
            @Decoratable
            protocol TestProtocol { }
            """,
            expandedSource: """
            protocol TestProtocol { }
            """,
            macros: testMacros
        )
    }

    func testProtocolWithOneFunctionWithDecoratable() throws {
        assertMacroExpansion(
            """
            @Decoratable
            protocol Foo { 
                func bar()
            }
            """,
            expandedSource: """
            protocol Foo { 
                func bar()
            }
            
            class FooDecorator: Foo {
                private var decoree: any Foo
                 init(_ decoree: any Foo) {
                    self.decoree = decoree
                }
                 func bar() {
                    decoree.bar()
                }
            }
            """,
            macros: testMacros
        )
    }

    func testProtocolWithOneFunctionWithReturnDecoratable() throws {
        assertMacroExpansion(
            """
            @Decoratable
            protocol Foo { 
                func bar() -> Int
            }
            """,
            expandedSource: """
            protocol Foo { 
                func bar() -> Int
            }
            
            class FooDecorator: Foo {
                private var decoree: any Foo
                 init(_ decoree: any Foo) {
                    self.decoree = decoree
                }
                 func bar() -> Int {
                    decoree.bar()
                }
            }
            """,
            macros: testMacros
        )
    }

    func testProtocolWithOneFunctionWithOneParameterDecoratable() throws {
        assertMacroExpansion(
            """
            @Decoratable
            protocol Foo { 
                func bar(a: Int)
            }
            """,
            expandedSource: """
            protocol Foo { 
                func bar(a: Int)
            }
            
            class FooDecorator: Foo {
                private var decoree: any Foo
                 init(_ decoree: any Foo) {
                    self.decoree = decoree
                }
                 func bar(a: Int) {
                    decoree.bar(a: a)
                }
            }
            """,
            macros: testMacros
        )
    }

    func testPublicProtocolWithOneFunctionWithOneParameterDecoratable() throws {
        assertMacroExpansion(
            """
            @Decoratable
            public protocol Foo { 
                func bar(a: Int)
            }
            """,
            expandedSource: """
            public protocol Foo { 
                func bar(a: Int)
            }
            
            open class FooDecorator: Foo {
                private var decoree: any Foo
                public init(_ decoree: any Foo) {
                    self.decoree = decoree
                }
                open func bar(a: Int) {
                    decoree.bar(a: a)
                }
            }
            """,
            macros: testMacros
        )
    }

    func testProtocolWithOneMutatingFunctionWithDecoratable() throws {
        assertMacroExpansion(
            """
            @Decoratable
            protocol Foo { 
                mutating func bar()
            }
            """,
            expandedSource: """
            protocol Foo { 
                mutating func bar()
            }
            
            class FooDecorator: Foo {
                private var decoree: any Foo
                 init(_ decoree: any Foo) {
                    self.decoree = decoree
                }
                 func bar() {
                    decoree.bar()
                }
            }
            """,
            macros: testMacros
        )
    }
}
