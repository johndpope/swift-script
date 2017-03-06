import Runes
import TryParsec

fileprivate func asStmt(stmt: Statement) -> Statement {
    return stmt
}
let stmtSep = OHWS *> (VS <|> (semi <&> { _ in () })) <* OWS

let stmtBraceItems = _stmtBraceItems()
func _stmtBraceItems() -> SwiftParser<[Statement]> {
    return sepEndBy(stmtBraceItem, stmtSep)
}

let stmtBraceItem = _stmtBraceItem()
func _stmtBraceItem() -> SwiftParser<Statement> {
    return (decl <&> asStmt)
        <|> (stmt <&> asStmt)
        <|> (expr <&> asStmt)
}


let stmtBrace = _stmtBrace()
func _stmtBrace() -> SwiftParser<[Statement]> {
    return  l_brace *> OWS *> stmtBraceItems <* OWS <* r_brace
}

let stmt = _stmt()
func _stmt() -> SwiftParser<Statement> {
    return (stmtReturn <&> asStmt)
        <|> (stmtThrow <&> asStmt)
        <|> (stmtDefer <&> asStmt)
        <|> (stmtIf <&> asStmt)
        <|> (stmtGuard <&> asStmt)
        <|> (stmtForIn <&> asStmt)
//        <|> (stmtDo <&> asStmt)
        <|> (stmtBreak <&> asStmt)
        <|> (stmtContinue <&> asStmt)
        <|> (stmtFallthrough <&> asStmt)
}


let stmtForIn = _stmtForIn()
func _stmtForIn() -> SwiftParser<ForInStatement> {
    return { name in { col in { body in
        ForInStatement(item: name, collection: col, statements: body) }}}
        <^> (kw_for *> WS *> identifier)
        <*> (WS *> kw_in *> OWS *> exprBasic)
        <*> (OWS *> stmtBrace)
}

func _stmtWhile() -> SwiftParser<WhileStatement> {
    return fail("not implemented")
}

func _stmtRepeatWhile() -> SwiftParser<RepeatWhileStatement> {
    return fail("not implemented")
}

let stmtIf = _stmtIf()
func _stmtIf() -> SwiftParser<IfStatement> {
    return { cond in { body in { els in
        IfStatement(condition: cond, statements: body, elseClause: els) }}}
        <^> (kw_if *> OWS *> exprBasic)
        <*> (OWS *> stmtBrace)
        <*> stmtElseClause
}

let stmtElseClause = _stmtElseClause()
func _stmtElseClause() -> SwiftParser<ElseClause?> {
    return (OWS *> kw_else *> WS *> stmtIf <&> { .elseIf($0) })
        <|> (OWS *> kw_else *> OWS *> stmtBrace <&> { .else_($0)} )
        <|> pure(nil)
}

let stmtGuard = _stmtGuard()
func _stmtGuard() -> SwiftParser<GuardStatement> {
    return { cond in { body in
        GuardStatement(condition: cond, statements: body) }}
        <^> (kw_guard *> OWS *> exprBasic)
        <*> (OWS *> kw_else *> OWS *> stmtBrace)
}

func _stmtSwitch() -> SwiftParser<SwitchStatement> {
    return fail("not implemented")
}

func _stmtLabeled() -> SwiftParser<LabeledStatement> {
    return fail("not implemented")
}

let stmtBreak = _stmtBreak()
func _stmtBreak() -> SwiftParser<BreakStatement> {
    return BreakStatement.init <^> kw_break *> zeroOrOne(WS *> identifier)
}

let stmtContinue = _stmtContinue()
func _stmtContinue() -> SwiftParser<ContinueStatement> {
    return ContinueStatement.init <^> kw_continue *> zeroOrOne(WS *> identifier)
}

let stmtFallthrough = _stmtFallthrough()
func _stmtFallthrough() -> SwiftParser<FallthroughStatement> {
    return { _ in FallthroughStatement() } <^> kw_fallthrough
}

let stmtReturn = _stmtReturn()
func _stmtReturn() -> SwiftParser<ReturnStatement> {
    return { value in
        ReturnStatement(expression: value) }
        <^> kw_return
        *> zeroOrOne(OWS *> expr)
}

let stmtThrow = _stmtThrow()
func _stmtThrow() -> SwiftParser<ThrowStatement> {
    return { value in
        ThrowStatement(expression: value) }
        <^> (kw_throw *> OWS *> expr)
}

let stmtDefer = _stmtDefer()
func _stmtDefer() -> SwiftParser<DeferStatement> {
    return { stmts in
        DeferStatement(statements: stmts) }
        <^> (kw_defer *> OWS *> stmtBrace)
}


func _stmtDo() -> SwiftParser<DoStatement> {
    return fail("not implemented")
}

func _stmtCatchClause() -> SwiftParser<CatchClause> {
    return fail("not implemented")
}
