import SwiftAST

extension JavaScriptTranslator {
    func visit(_ n: ForInStatement) throws -> String {
        return "\(indent(of: indentLevel))for (\(n.item) of \(try n.collection.accept(JavaScriptTranslator(indentLevel: indentLevel)))) \(try translateBlock(wrapping: n.statements, with: indentLevel))\n"
    }
    
    func visit(_ n: WhileStatement) throws -> String {
        return "\(indent(of: indentLevel))while (\(try n.condition.accept(JavaScriptTranslator(indentLevel: indentLevel)))) \(try translateBlock(wrapping: n.statements, with: indentLevel))\n"
    }
    
    func visit(_ n: RepeatWhileStatement) throws -> String {
        return "\(indent(of: indentLevel))repeat \(try translateBlock(wrapping: n.statements, with: indentLevel)) while (\(try n.condition.accept(JavaScriptTranslator(indentLevel: indentLevel))))\n"
    }
    
    func visit(_ n: IfStatement) throws -> String {
        return "\(indent(of: indentLevel))\(try _visit(n))"
    }
    
    private func _visit(_ n: IfStatement) throws -> String {
        let jsIf: String
        switch n.condition {
        case let .boolean(expression):
            jsIf = "if (\(try expression.accept(JavaScriptTranslator(indentLevel: indentLevel)))) \(try translateBlock(wrapping: n.statements, with: indentLevel))"
            guard let elseClause = n.elseClause else {
                return "\(jsIf)\n"
            }
            switch elseClause {
            case let .elseIf(ifStatement):
                return "\(jsIf) else \(try _visit(ifStatement))"
            case let .else_(statements):
                return "\(jsIf) else \(try translateBlock(wrapping: statements, with: indentLevel))\n"
            }
        case let .optionalBinding(_, name, expression):
            if let expression = expression as? IdentifierExpression, expression.identifier == name {
                return try IfStatement(
                    condition: .boolean(BinaryOperation(
                        leftOperand: IdentifierExpression(identifier: name),
                        operatorSymbol: "!=",
                        rightOperand: NilLiteral()
                    )),
                    statements: n.statements,
                    elseClause: n.elseClause
                ).accept(JavaScriptTranslator(indentLevel: indentLevel))
            }
            
            return try DoStatement(statements: [
                DeclarationStatement(
                    VariableDeclaration(isStatic: false, name: name, type: nil, expression: nil)
                ),
                IfStatement(
                    condition: .boolean(BinaryOperation(
                        leftOperand: ParenthesizedExpression(expression: BinaryOperation(
                            leftOperand: IdentifierExpression(identifier: name),
                            operatorSymbol: "=",
                            rightOperand: expression
                        )),
                        operatorSymbol: "!=",
                        rightOperand: NilLiteral()
                    )),
                    statements: n.statements,
                    elseClause: nil
                ),
            ], catchClauses: []).accept(JavaScriptTranslator(indentLevel: indentLevel))
        }
    }
    
    func visit(_ n: GuardStatement) throws -> String {
        switch n.condition {
        case let .boolean(expression):
            return try IfStatement(
                condition: .boolean(PrefixUnaryOperation(operatorSymbol: "!", operand: ParenthesizedExpression(expression: expression))),
                statements: n.statements,
                elseClause: nil
            ).accept(JavaScriptTranslator(indentLevel: indentLevel))
        case let .optionalBinding(_, name, expression):
            if let expression = expression as? IdentifierExpression, expression.identifier == name {
                return try IfStatement(
                    condition: .boolean(BinaryOperation(
                        leftOperand: IdentifierExpression(identifier: name),
                        operatorSymbol: "==",
                        rightOperand: NilLiteral()
                    )),
                    statements: n.statements,
                    elseClause: nil
                ).accept(JavaScriptTranslator(indentLevel: indentLevel))
            }
            
            return try translate([
                DeclarationStatement(VariableDeclaration(isStatic: false, name: name, type: nil, expression: nil)),
                IfStatement(
                    condition: .boolean(BinaryOperation(
                        leftOperand: ParenthesizedExpression(expression: BinaryOperation(
                            leftOperand: IdentifierExpression(identifier: name),
                            operatorSymbol: "=",
                            rightOperand: expression
                        )),
                        operatorSymbol: "==",
                        rightOperand: NilLiteral()
                    )),
                    statements: n.statements,
                    elseClause: nil
                ),
            ], with: indentLevel)
        }
        
    }
    
    func visit(_: SwitchStatement) throws -> String {
        throw UnimplementedError()
    }

    func visit(_ n: LabeledStatement) throws -> String {
        let indentDepth = indent(of: indentLevel).characters.count
        let characters: String.CharacterView = try n.statement.accept(JavaScriptTranslator(indentLevel: indentLevel)).characters
        let statementWithoutIndent = String(characters.dropFirst(indentDepth))
        return "\(indent(of: indentLevel))\(n.labelName): \(statementWithoutIndent)"
    }
    
    func visit(_ n: BreakStatement) throws -> String {
        if let labelName = n.labelName {
            return "\(indent(of: indentLevel))break \(labelName);\n"
        } else {
            return "\(indent(of: indentLevel))break;\n"
        }
    }
    
    func visit(_ n: ContinueStatement) throws -> String {
        if let labelName = n.labelName {
            return "\(indent(of: indentLevel))continue \(labelName);\n"
        } else {
            return "\(indent(of: indentLevel))continue;\n"
        }
    }
    
    func visit(_ n: FallthroughStatement) throws -> String {
        return ""
    }
    
    func visit(_ n: ReturnStatement) throws -> String {
        if let expression = n.expression {
            return "\(indent(of: indentLevel))return \(try expression.accept(JavaScriptTranslator(indentLevel: indentLevel)));\n"
        } else {
            return "\(indent(of: indentLevel))return;\n"
        }
    }
    
    func visit(_ n: ThrowStatement) throws -> String {
        return "\(indent(of: indentLevel))throw \(try n.expression.accept(JavaScriptTranslator(indentLevel: indentLevel)));\n"
    }
    
    func visit(_: DeferStatement) throws -> String {
        throw UnimplementedError()
    }

    func visit(_ n: DoStatement) throws -> String {
        // TODO: catch
        return "\(indent(of: indentLevel))\(try translateBlock(wrapping: n.statements, with: indentLevel))\n"
    }
    
    func visit(_ n: ExpressionStatement) throws -> String {
        return "\(indent(of: indentLevel))\(try n.expression.accept(JavaScriptTranslator(indentLevel: indentLevel)));\n"
    }
    
    func visit(_ n: DeclarationStatement) throws -> String {
        return try n.declaration.accept(JavaScriptTranslator(indentLevel: indentLevel))
    }
}
