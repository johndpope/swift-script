import SwiftAST

struct SupportingLibrary {
    static let defaultNamespace = "$ss"
    
    struct Function {
        let name: String
        let declaration: String
        
        private static let idToFunction: [Id: Function] = {
            var idToFunction: [Id: Function] = [:]
            for id in Id.values {
                idToFunction[id] = Function(id)
            }
            return idToFunction
        }()
        
        init(id: Id) {
            self = Function.idToFunction[id]!
        }
        
        private init(_ id: Id) {
            switch id {
            case .forcedCast:
                name =  "asx"
                declaration = "    function asx(expression, type_test) {\n        if type_test() {\n            throw Error(\"Failed to cast\");\n        }\n        return expression;\n    }"
            case .optionalCast:
                name =  "asq"
                declaration = "    function asq(expression, type_test) {\n        return type_test() ? expression : null;\n    }"
            case .forcedTry:
                name =  "tryx"
                declaration = "    function tryx(command) {\n        try {\n            return command();\n        }\n        catch(e) {\n            // TODO: some force stopping method\n            throw e;\n        }\n    }"
            case .optionalTry:
                name =  "tryq"
                declaration = "    function tryq(command) {\n        try {\n            return command();\n        }\n        catch(e) {\n            return null;\n        }\n    }"
            case .forcedUnwrapping:
                name =  "x"
                declaration = "    function x(expression) {\n        const is_null = (expression == null || typeof expression == 'undefined');\n        if (is_null) {\n            throw Error(\"Failed unwrapping\");\n        }\n        return expression;\n    }"
            case .optionalChaining:
                name =  "q"
                declaration = "    function q(expression, command) {\n        const is_null = (expression == null || typeof expression == 'undefined');\n        return is_null ? null : command();\n    }"
            case .range:
                name =  "range"
                declaration = "    function range(from, to) {\n        return (function* () {\n            var current = from;\n            while (current < to) {\n                yield current++;\n            }\n        })();\n    }"
            case .closedRange:
                name =  "closedRange"
                declaration = "    function closedRange(from, to) {\n        return (function* () {\n            var current = from;\n            while (current <= to) {\n                yield current++;\n            }\n        })();\n    }"
            case .typeChecking:
                name =  "is"
                declaration = "    function is(expression, type) {\n        if (type == String) {\n            return typeof (expression) == 'string' || expression instanceof String;\n        } else if (type == Number) {\n            return typeof (expression) == 'number' || expression instanceof Number;\n        }\n        return expression instanceof type;\n    }"
            case .nilCoalescing:
                name =  "qq"
                declaration = "    function qq(expression, value) {\n        const is_null = (expression == null || typeof expression == 'undefined');\n        return is_null ? value : expression;\n    }"
            }
        }
        
        func callExpression(expression: Expression, arguments: [Expression], namepace: String = SupportingLibrary.defaultNamespace) -> FunctionCallExpression {
            return FunctionCallExpression(expression: ExplicitMemberExpression(expression: expression, member: name), arguments: arguments.map { (nil, $0) }, trailingClosure: nil)
        }
        
        enum Id {
            case forcedCast
            case optionalCast
            case forcedTry
            case optionalTry
            case forcedUnwrapping
            case optionalChaining
            case range
            case closedRange
            case typeChecking
            case nilCoalescing
            
            static let values: [Id] = [
                .forcedCast,
                .optionalCast,
                .forcedTry,
                .optionalTry,
                .forcedUnwrapping,
                .optionalChaining,
                .range,
                .closedRange,
                .typeChecking,
                .nilCoalescing,
            ]
        }
    }

    static func javaScript(for ids: Set<Function.Id>, namespace: String = defaultNamespace) -> String {
        let namespaceVariable = "ns"
        let functionDeclarations = ids.map { id -> String in
            let function = Function(id: id)
            return "\(function.declaration)\n    \(namespaceVariable).\(function.name) = \(function.name);"
        }.joined(separator: "\n")

        return [
            "\(namespace) = {};",
            "((\(namespaceVariable)) => {",
            functionDeclarations,
            "})(\(namespace));"
        ].joined(separator: "\n")
    }
}
