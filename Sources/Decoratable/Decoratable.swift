/// A macro that produces Decoration pattern implementation
/// for the atteched protocol. For example,
///
///     @Decoratable
///     protocol Foo {
///         func bar()
///     }
///
/// produces a Decorator class `
///     class FooDecorator: Foo {
///         private let decoree: any Foo
///         init(decoree: any Foo) { self.decoree = decoree }
///         func bar() { decoree.bar() }
///     }
/// `

@attached(peer, names: suffixed(Decorator))
public macro Decoratable() = #externalMacro(module: "DecoratableMacros", type: "DecoratableMacro")
