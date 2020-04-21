from lark import Lark

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
            
    updateexp : I ASSIGN exp
            | I DPLUS
            | I DMINUS
            
    mathexp : mathexp ADD mathexp
            | mathexp SUB mathexp
            | mathexp MUL mathexp
            | mathexp DIV mathexp
            | OBRAC mathexp CBRAC
            | I | N
                
    stringexp : stringexp ADD stringexp | S
    
    boolexp : boolean AND boolean
            | boolean OR boolean
            | NOT boolean
            | OBRAC boolean CBRAC
            
    exp : mathexp | stringexp | boolexp
    
    ter : boolean TIF exp TELSE exp
    
    values : I | N | S | boolean
    
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

text = '''
    int num = 5;
    string str = "hello";
    bool flag = true;
    string name;
    int age;
    bool isMarried;
    print x;
    End
'''

# text = '''
#     int x = 10;
#     x = false ? 1 : 2;
#     print x;
#     for i in range(1,10) {
#     int z = 2;
#     print z;
#     };
#     string str;
#     if (x/10 == 0) {
#         str = "x is a " + "multiple of 10";
#     print str;
#     } else {
#         str = "x is not a " + "multiple of 10";
#     print str;
#     };
#     int y = 1;
#     do {
#             y = y * 10;
#     } while (not(y == 100));
#     print true;
#     End
# '''
# 
# text1 = '''
#     print "Hello World!";
#     int y = 1;
#     for(int i = 0; i > x + 5; i = i / 3) {
#     y = y * 10;
#     if (x/10 == 0) {
#         str = "x is a ” + “multiple of 10";
#         print str;
#     } elseif {
#         str = "this is am middle piece";
#     } else {
#         str = "x is not a " + "multiple of 10";
#         print str;
#     };
#     };
#     int z = 5;
#     while(z >= 1) {
#         z = z -1;
#     };
#     End
# '''
generatedTree = lark_parser.parse(text)
modifiedTree = str(generatedTree) \
                .replace("Tree(", "tree(") \
                .replace("Token(", "token(") \
                .replace(" ","")
print(modifiedTree)
#tokens = []
#l = list(lark_parser.lex(text1))
#for each in l:
#    tokens.append(each.value)
#print(tokens)

