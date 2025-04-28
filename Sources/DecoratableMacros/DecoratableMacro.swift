import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `Decoratable` macro, which apply to protocol
/// wihout properties requirenments and produces a class which implements
/// that protocol and apply Decorator pattern. For example
///
///     @Decoratable
///     protocol Foo {
///         func bar()
///     }
///
///     will expand to
///
///     protocol Foo {
///         func bar()
///     }
///
///     class FooDecorator: Foo {
///         private let decoree: any Foo
///         init(decoree: any Foo) { self.decoree = decoree }
///         func bar() { decoree.bar() }
///     }
///

public struct DecoratableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Check that macro aplly to protocol
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw DecoratableMacroError.canOnlyAppleToProtocol
        }

        let notContainsVariables = protocolDecl.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }.isEmpty

        guard notContainsVariables else {
            throw DecoratableMacroError.canOnlyAppleToProtocol
        }

        let protocolName = protocolDecl.name.text
        let decoratorClassName = "\(protocolName)Decorator"

        // Take all protocol methods
        let functions = protocolDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }

        guard !functions.isEmpty else {
            // Not generate anything
            return []
        }


        let protocolAccessLevel = protocolDecl.modifiers
            .first { $0.name.tokenKind.isAccessLevelModifier }?
            .name.text ?? ""
        let decoratorAccessLevel = protocolAccessLevel == "public" ? "open " : protocolAccessLevel + " "

        // Generate Decorator methods
        let methodImpls = functions.map { funcDecl -> String in
            let funcName = funcDecl.name.text
            let parameters = funcDecl.signature.parameterClause.parameters

            // Формируем аргументы для вызова decoree
            var args = [String]()
            for param in parameters {
                let externalName = param.firstName.text
                let internalName = param.secondName?.text ?? param.firstName.text
                args.append(externalName == "_" ? "\(internalName)" : "\(externalName): \(internalName)")
            }

            // Тело метода
            let call = "decoree.\(funcName)(\(args.joined(separator: ", ")))"
            let body = call
            let parametersString = if parameters.isEmpty {
                "()"
            } else {
                "\(funcDecl.signature.parameterClause)"
            }
            let returnString = if let returnClause = funcDecl.signature.returnClause {
                " \(returnClause)"
            } else {
                ""
            }

            return "\(decoratorAccessLevel)func \(funcName)\(parametersString)\(returnString) { \(body) }"
        }.joined(separator: "\n")

        // Генерируем код класса-декоратора
        let classDecl = """
        \(decoratorAccessLevel)class \(decoratorClassName): \(protocolName) {
            private var decoree: any \(protocolName)
            \(protocolAccessLevel) init(_ decoree: any \(protocolName)) { self.decoree = decoree }
            \(methodImpls)
        }
        """
        return [DeclSyntax(stringLiteral: classDecl)]
    }
}

// MARK: - AccessLevelModifier

extension TokenKind {
    var isAccessLevelModifier: Bool {
        switch self {
        case .keyword(.public),
             .keyword(.private),
             .keyword(.fileprivate),
             .keyword(.internal),
             .keyword(.open):
            return true
        default:
            return false
        }
    }
}

enum DecoratableMacroError: CustomStringConvertible, Error {
    case canOnlyAppleToProtocol
    case protocolWithoutVariable

    var description: String {
        switch self {
        case .canOnlyAppleToProtocol:
            "@Decoratable can only be applied to a protocol."
        case .protocolWithoutVariable:
            "@Decoratable can only be applied to a protocol without variable requirements."
        }
    }
}

@main
struct DecoratablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DecoratableMacro.self,
    ]
}
