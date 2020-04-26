from lark import Lark
#from pyswip import Prolog
import sys

lark_parser = Lark(r'''
    program: block PEND
    
    block: (declarations)? commands
    
    declarations : (declaration SEMI)+
    
    declaration: INT I ASSIGN N
                | STRING I ASSIGN S
                | BOOL I ASSIGN TRUE
                | BOOL I ASSIGN FALSE
                | INT I
                | STRING I
                | BOOL I
    
    commands : (command)+
    
    command: IF OBRAC boolean CBRAC OCURL commands CCURL elseif ELSE OCURL commands CCURL SEMI
            | WHILE OBRAC boolean CBRAC OCURL commands CCURL SEMI
            | DO OCURL commands CCURL WHILE OBRAC boolean CBRAC SEMI
            | FOR OBRAC INT I ASSIGN N SEMI boolean SEMI updateexp CBRAC OCURL commands CCURL SEMI
            | FOR I IN RANGE OBRAC N COMMA N CBRAC OCURL commands CCURL SEMI
            | I ASSIGN exp SEMI
            | I ASSIGN ter SEMI
            | PRINT values SEMI
            | declarations
                
    elseif :  (ELIF OBRAC boolean CBRAC OCURL commands CCURL)*
    
    boolean : TRUE | FALSE
            | mathexp EQUALS mathexp
            | mathexp NOTEQUALS mathexp
            | mathexp LT mathexp
            | mathexp LTE mathexp
            | mathexp GT mathexp
            | mathexp GTE mathexp
            | stringexp EQUALS stringexp
            | boolexp
            
    updateexp : I ASSIGN mathexp
            | I DPLUS
            | I DMINUS
            
    mathexp : mathexp ADD mathexp
            | mathexp SUB mathexp
            | mathexp MUL mathexp
            | mathexp DIV mathexp
            | OBRAC mathexp CBRAC
            | identifier | number
                
    stringexp : stringexp ADD stringexp | S
    
    boolexp : boolean AND boolean
            | boolean OR boolean
            | NOT boolean
            | OBRAC boolean CBRAC
            
    exp : mathexp | stringexp | boolexp
    
    ter : boolean TIF exp TELSE exp
    
    values : I | N | S | boolean
    
    identifier: I
    
    number: N
    
    BEND : "BEnd"
    PEND : "End"
    SEMI : ";"
    COMMA : ","
    INT     : "int"
    ASSIGN  : "="
    DPLUS    : "++"
    DMINUS    : "--"
    EQUALS    : "=="
    NOTEQUALS    : "!="
    LT    : "<"
    LTE    : "<="
    GT    : ">"
    GTE    : ">="
    ADD    : "+"
    SUB    : "-"
    MUL    : "*"
    DIV    : "/"
    AND    : "and"
    OR    : "or"
    NOT    : "not"
    STRING  : "string"
    BOOL    : "bool"
    IF      : "if"
    ELSE    : "else"
    ELIF    : "elif"
    WHILE    : "while"
    DO        : "do"
    FOR        : "for"
    IN        : "in"
    RANGE    : "range"
    OBRAC    : "("
    CBRAC    : ")"
    OCURL    : "{"
    CCURL    : "}"
    PRINT    : "print"
    TIF    : "?"
    TELSE    : ":"
    TRUE    : "true"
    FALSE    : "false"
    
    
    %import common.ESCAPED_STRING -> S
    %import common.SIGNED_NUMBER -> N
    %import common.WORD -> I
    %import common.WS
    %ignore WS

    ''', start='program', parser='lalr')

with open(sys.argv[1], 'r') as file:
    text = file.read()

generatedTree = lark_parser.parse(text)
modifiedTree = str(generatedTree) \
                .replace("Tree(", "tree(") \
                .replace("Token(", "token(") \
                .replace(" ","")
print(modifiedTree)
