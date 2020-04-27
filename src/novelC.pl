run_program(P):- eval_program(P, []).

eval_program(tree(program,[BlockTree,_]), InitialEnv):-
    eval_block(BlockTree,InitialEnv, _FinalEnv).

%%=======BLOCK========%%
eval_block(tree(block,[CommandsTree]),InitialEnv, FinalEnv):-
    eval_commands(CommandsTree,InitialEnv, FinalEnv).

eval_block(tree(block,[DeclarationsTree,CommandsTree]),InitialEnv, FinalEnv):-
    eval_declarations(DeclarationsTree,InitialEnv, TempEnv),
    eval_commands(CommandsTree,TempEnv, FinalEnv).

%%=====Declarations====%%
eval_declarations(tree(declarations,[SingleDeclaration,_]), InitialEnv, FinalEnv):-
    eval_single_declaration(SingleDeclaration, InitialEnv, FinalEnv).

eval_declarations(tree(declarations,[FirstDeclaration,_|RemDeclaration]), InitialEnv, FinalEnv):-
    RemDeclaration \= [],
    eval_single_declaration(FirstDeclaration, InitialEnv, TempEnv),
    eval_declarations(tree(declarations,RemDeclaration), TempEnv, FinalEnv).

%%=====Declaration====%%
eval_single_declaration(tree(declaration,[token(_INT,'int'),token(_I,Identifier),_,token(_N,Val)]), InitialEnv, FinalEnv):-
    atom_number(Val, NewVal),
    updateEnv(Identifier,NewVal,InitialEnv,FinalEnv).

eval_single_declaration(tree(declaration,[token(_STRING,'string'),token(_I,Identifier),_,token(_S,Val)]), InitialEnv, FinalEnv):-
    updateEnv(Identifier,Val,InitialEnv,FinalEnv).

eval_single_declaration(tree(declaration,[token(_BOOL,'bool'),token(_I,Identifier),_,token(_TRUE,Val)]), InitialEnv, FinalEnv):-
    updateEnv(Identifier,Val,InitialEnv,FinalEnv).

eval_single_declaration(tree(declaration,[token(_INT,'int'),token(_I,Identifier)]), InitialEnv, FinalEnv):-
    updateEnv(Identifier,0,InitialEnv,FinalEnv).

eval_single_declaration(tree(declaration,[token(_STRING,'string'),token(_I,Identifier)]), InitialEnv, FinalEnv):-
    updateEnv(Identifier,"",InitialEnv,FinalEnv).

eval_single_declaration(tree(declaration,[token(_BOOL,'bool'),token(_I,Identifier)]), InitialEnv, FinalEnv):-
    updateEnv(Identifier,true,InitialEnv,FinalEnv).

%%=====Commands======%%
eval_commands(tree(commands,[SingleCommand]), InitialEnv, FinalEnv):-
    eval_single_command(SingleCommand, InitialEnv, FinalEnv).

eval_commands(tree(commands,[FirstCommand|RemCommand]), InitialEnv, FinalEnv):-
    RemCommand \= [],
    eval_single_command(FirstCommand, InitialEnv, TempEnv),
    eval_commands(tree(commands,RemCommand), TempEnv, FinalEnv).

%%=====Command If-Else======%%
eval_single_command(tree(command,[token(_IF,'if'),_,BooleanTree,_,_,CommandsTree1,_,_,_,_,_,_,_]),  InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, true),
    eval_commands(CommandsTree1,InitialEnv, FinalEnv).
eval_single_command(tree(command,[token(_IF,'if'),_,BooleanTree,_,_,_,_,ElseifTree,_,_,CommandsTree2,_,_]),  InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, false),
    eval_elseif(ElseifTree, InitialEnv, TempEnv, false),
    eval_commands(CommandsTree2, TempEnv, FinalEnv).
eval_single_command(tree(command,[token(_IF,'if'),_,BooleanTree,_,_,_,_,ElseifTree,_,_,_,_,_]),  InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, false),
    eval_elseif(ElseifTree, InitialEnv, TempEnv, true),
    FinalEnv = TempEnv.

%%=====Command While======%%
eval_single_command(tree(command,[token(_WHILE,'while'),_,BooleanTree,_,_,CommandsTree,_,_]),  InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, true),
    eval_commands(CommandsTree,InitialEnv, TempEnv1),
    eval_single_command(tree(command,[token(_,'while'),_,BooleanTree,_,_,CommandsTree,_,_]),  TempEnv1, FinalEnv).
eval_single_command(tree(command,[token(_WHILE,'while'),_,BooleanTree,_,_,_,_,_]),  InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, false),
    FinalEnv = InitialEnv.

%%=====Command Do-While======%%
eval_single_command(tree(command,[token(_DO,'do'),_,CommandsTree,_,_,_,BooleanTree,_,_]),  InitialEnv, FinalEnv):-
    eval_commands(CommandsTree,InitialEnv, TempEnv),
    eval_while_loop(CommandsTree,BooleanTree,  TempEnv, FinalEnv).

%%========Traditional For-Loop=========%%
eval_single_command(tree(command,[token(_FOR,'for'),_,_,token(_I,I),_,token(_N,N),_,BooleanTree,_,UpdateTree,_,_,CommandsTree,_,_]),  InitialEnv, FinalEnv):-
    atom_number(N, NewN),
    updateEnv(I, NewN, InitialEnv, TempEnv),
    eval_for_loop(BooleanTree,UpdateTree,CommandsTree,TempEnv,FinalEnv).

%%========For-Range Loop=========%%
eval_single_command(tree(command,[token(_FOR,'for'),token(_I,I),_,_,_,token(_N1,N1),_,token(_N2,N2),_,_,CommandsTree,_,_]), InitialEnv, FinalEnv):-
    atom_number(N1,NewN1),
    atom_number(N2,NewN2),
    updateEnv(I, NewN1, InitialEnv, TempEnv),
    eval_range_loop(I,NewN1,NewN2,CommandsTree, TempEnv, FinalEnv).

%%======= I = Exp =========%%
eval_single_command(tree(command,[token(_I,I),_,ExpressionTree,_]), InitialEnv, FinalEnv):-
    eval_expr(ExpressionTree,InitialEnv,Value),
    updateEnv(I,Value,InitialEnv,FinalEnv).

%%======= I = Ter =========%%
eval_single_command(tree(command,[token(_I,I),_,TernaryTree,_]), InitialEnv, FinalEnv):-
    eval_ternary(TernaryTree,InitialEnv,Value),
    updateEnv(I,Value,InitialEnv,FinalEnv).

%%======= Declaration inside command==%%
eval_single_command(tree(command,[DeclarationsTree]), InitialEnv, FinalEnv):-
    eval_declarations(DeclarationsTree, InitialEnv, FinalEnv).

%%=====Command Print======%%
eval_single_command(tree(command,[token(_PRINT,print),ValuesTree,_]), InitialEnv, FinalEnv):-
    FinalEnv = InitialEnv,
    eval_values(ValuesTree, InitialEnv, Value),
    write(Value),
    nl.

%%======= For Helper======%%
eval_for_loop(BooleanTree,UpdateTree,CommandsTree,TempEnv,FinalEnv):-
    eval_boolean(BooleanTree, TempEnv, true),
    eval_commands(CommandsTree,TempEnv, TempEnv1),
    eval_update_expr(UpdateTree, TempEnv1, TempEnv2),
    eval_for_loop(BooleanTree,UpdateTree,CommandsTree,TempEnv2,FinalEnv).

eval_for_loop(BooleanTree,_UpdateTree,_CommandsTree,TempEnv,FinalEnv):-
    eval_boolean(BooleanTree, TempEnv, false),
    FinalEnv = TempEnv.

eval_range_loop(_I,N1,N2,_CommandsTree, InitialEnv, FinalEnv):-
    N1 >= N2,
    FinalEnv = InitialEnv.

eval_range_loop(I,N1,N2,CommandsTree, InitialEnv, FinalEnv):-
    N1 < N2,
    eval_commands(CommandsTree, InitialEnv, TempEnv),
    NewN1 is N1+1,
    updateEnv(I,NewN1,TempEnv,TempEnv1),
    eval_range_loop(I,NewN1,N2,CommandsTree, TempEnv1, FinalEnv).

%%========= do-while helper======%%
eval_while_loop(CommandsTree,BooleanTree,  InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, true),
    eval_commands(CommandsTree,InitialEnv, TempEnv),
    eval_while_loop(CommandsTree,BooleanTree,  TempEnv, FinalEnv).
eval_while_loop(_CommandsTree,BooleanTree, InitialEnv, FinalEnv):-
    eval_boolean(BooleanTree, InitialEnv, false),
    FinalEnv = InitialEnv.

%%======Else-If=======%%
eval_elseif(tree(elseif,[]),InitialEnv,InitialEnv,false).
eval_elseif(tree(elseif,[token(_ELIF,'elif'),_,BooleanTree,_,_,CommandsTree,_|_RemElseIf]), InitialEnv, FinalEnv, Status):-
    eval_boolean(BooleanTree, InitialEnv, true),
    eval_commands(CommandsTree,InitialEnv, FinalEnv),
    Status = true.
eval_elseif(tree(elseif,[token(_ELIF,'elif'),_,BooleanTree,_,_,_CommandsTree,_|RemElseIf]), InitialEnv, FinalEnv, Status):-
    eval_boolean(BooleanTree, InitialEnv, false),
    eval_elseif(tree(elseif,RemElseIf), InitialEnv, FinalEnv, Status).

%%=====Boolean=======%%
eval_boolean(tree(boolean,[token(_TRUE,true)]),_InitialEnv,true).
eval_boolean(tree(boolean,[token(_FALSE,false)]),_InitialEnv,false).

%%=====Boolean Equals=======%%
eval_boolean(tree(boolean,[MathExprTree1,token(_EQUALS,'=='),MathExprTree2]),InitialEnv,true):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 = Value2.
eval_boolean(tree(boolean,[MathExprTree1,token(_EQUALS,'=='),MathExprTree2]),InitialEnv,false):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 \= Value2.

%%=====Boolean Not Equals=======%%
eval_boolean(tree(boolean,[MathExprTree1,token(_NOTEQUALS,'!='),MathExprTree2]),InitialEnv,true):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 \= Value2.
eval_boolean(tree(boolean,[MathExprTree1,token(_NOTEQUALS,'!='),MathExprTree2]),InitialEnv,false):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 = Value2.

%%=====Boolean Less Than=======%%
eval_boolean(tree(boolean,[MathExprTree1,token(_LT,'<'),MathExprTree2]),InitialEnv,true):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 < Value2.
eval_boolean(tree(boolean,[MathExprTree1,token(_LT,'<'),MathExprTree2]),InitialEnv,false):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 >= Value2.

%%=====Boolean Less Than Equals=======%%
eval_boolean(tree(boolean,[MathExprTree1,token(_LTE,'<='),MathExprTree2]),InitialEnv,true):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 =< Value2.
eval_boolean(tree(boolean,[MathExprTree1,token(_LTE,'<='),MathExprTree2]),InitialEnv,false):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 > Value2.

%%=====Boolean Greater Than=======%%
eval_boolean(tree(boolean,[MathExprTree1,token(_GT,'>'),MathExprTree2]),InitialEnv,true):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 > Value2.
eval_boolean(tree(boolean,[MathExprTree1,token(_GT,'>'),MathExprTree2]),InitialEnv,false):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 =< Value2.

%%=====Boolean Greater Than Equals>=======%%
eval_boolean(tree(boolean,[MathExprTree1,token(_GTE,'>='),MathExprTree2]),InitialEnv,true):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 >= Value2.
eval_boolean(tree(boolean,[MathExprTree1,token(_GTE,'>='),MathExprTree2]),InitialEnv,false):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math_expr(MathExprTree2, InitialEnv, Value2),
    Value1 < Value2.

%%=====Boolean String Equals=======%%
eval_boolean(tree(boolean,[StringExprTree1,token(_EQUALS,'=='),StringExprTree2]),_InitialEnv,true):-
    eval_string_expr(StringExprTree1, Value1),
    eval_string_expr(StringExprTree2, Value2),
    Value1 = Value2.
eval_boolean(tree(boolean,[StringExprTree1,token(_EQUALS,'=='),StringExprTree2]),_InitialEnv,false):-
    eval_string_expr(StringExprTree1, Value1),
    eval_string_expr(StringExprTree2, Value2),
    Value1 \= Value2.

%%=====Boolean - Boolean Expression=======%%
eval_boolean(tree(boolean,[BooleanExpr]),InitialEnv,Value):-
    eval_boolean_expr(BooleanExpr, InitialEnv, Value).

%%=====Update expression===%%
eval_update_expr(tree(updateexp,[token(_I,I),token(_DPLUS,'++')]), InitialEnv, FinalEnv):-
    lookupEnv(I,InitialEnv,Value),
    NewValue is Value + 1,
    updateEnv(I,NewValue,InitialEnv,FinalEnv).
eval_update_expr(tree(updateexp,[token(_I,I),token(_DMINUS,'--')]), InitialEnv, FinalEnv):-
    lookupEnv(I,InitialEnv,Value),
    NewValue is Value - 1,
    updateEnv(I,NewValue,InitialEnv,FinalEnv).
eval_update_expr(tree(updateexp,[token(_I,I),_,MathExprTree]), InitialEnv, FinalEnv):-
    eval_math_expr(MathExprTree, InitialEnv, Value),
    updateEnv(I,Value,InitialEnv,FinalEnv).

%%=====Math expression===%%
eval_math_expr(tree(mathexp,[MathExprTree1,token(_ADD,'+'),MathExprTree2]), InitialEnv, Value):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math1_expr(MathExprTree2, InitialEnv, Value2),
    Value is Value1 + Value2.
eval_math_expr(tree(mathexp,[MathExprTree1,token(_SUB,'-'),MathExprTree2]), InitialEnv, Value):-
    eval_math_expr(MathExprTree1, InitialEnv, Value1),
    eval_math1_expr(MathExprTree2, InitialEnv, Value2),
    Value is Value1 - Value2.
eval_math_expr(X, InitialEnv, Value):- eval_math1_expr(X, InitialEnv, Value).

eval_math1_expr(tree(mathexp,[MathExprTree1,token(_MUL,'*'),MathExprTree2]), InitialEnv, Value):-
    eval_math1_expr(MathExprTree1, InitialEnv, Value1),
    eval_math2_expr(MathExprTree2, InitialEnv, Value2),
    Value is Value1 * Value2.
eval_math1_expr(tree(mathexp,[MathExprTree1,token(_DIV,'/'),MathExprTree2]), InitialEnv, Value):-
    eval_math1_expr(MathExprTree1, InitialEnv, Value1),
    eval_math2_expr(MathExprTree2, InitialEnv, Value2),
    Value is Value1 / Value2.
eval_math1_expr(X, InitialEnv, Value):- eval_math2_expr(X, InitialEnv, Value).

eval_math2_expr(tree(mathexp,[_,MathExprTree,_]), InitialEnv, Value):-
    eval_math_expr(MathExprTree, InitialEnv, Value).
eval_math2_expr(tree(mathexp,[tree(number,[token(_N,NewVal)])]), _InitialEnv, Value):- 
    atom_number(NewVal, Value).
eval_math2_expr(tree(mathexp,[tree(identifier,[token(_I,I)])]), InitialEnv, Value):-
    lookupEnv(I,InitialEnv,Value).

%%=====String expression===%%
eval_string_expr(tree(stringexp,[token(_S,Value)]), Value).

eval_string_expr(tree(stringexp,[StringExprTree1,token(_ADD,'+'),StringExprTree2]), Value):-
    eval_string_expr(StringExprTree1, Value1),
    eval_string_expr(StringExprTree2, Value2),
    string_concat(Value1,Value2,Value).

%%=====Boolean expression===%%
eval_boolean_expr(tree(boolexp,[BooleanTree1,token(_OR,'or'),BooleanTree2]), InitialEnv, true):-
    eval_boolean(BooleanTree1,InitialEnv,true),
    eval_boolean(BooleanTree2,InitialEnv,true).
eval_boolean_expr(tree(boolexp,[BooleanTree1,token(_OR,'or'),BooleanTree2]), InitialEnv, true):-
    eval_boolean(BooleanTree1,InitialEnv,true),
    eval_boolean(BooleanTree2,InitialEnv,false).
eval_boolean_expr(tree(boolexp,[BooleanTree1,token(_OR,'or'),BooleanTree2]), InitialEnv, true):-
    eval_boolean(BooleanTree1,InitialEnv,false),
    eval_boolean(BooleanTree2,InitialEnv,true).
eval_boolean_expr(tree(boolexp,[BooleanTree1,token(_OR,'or'),BooleanTree2]), InitialEnv, false):-
    eval_boolean(BooleanTree1,InitialEnv,false),
    eval_boolean(BooleanTree2,InitialEnv,false).
eval_boolean_expr(X, InitialEnv, false):- eval_boolean1_expr(X, InitialEnv, false).

eval_boolean1_expr(tree(boolexp,[BooleanTree1,token(_AND,'and'),BooleanTree2]), InitialEnv, true):-
    eval_boolean(BooleanTree1,InitialEnv,true),
    eval_boolean(BooleanTree2,InitialEnv,true).
eval_boolean1_expr(tree(boolexp,[BooleanTree1,token(_AND,'and'),BooleanTree2]), InitialEnv, false):-
    eval_boolean(BooleanTree1,InitialEnv,false),
    eval_boolean(BooleanTree2,InitialEnv,false).
eval_boolean1_expr(tree(boolexp,[BooleanTree1,token(_AND,'and'),_]), InitialEnv, false):-
    eval_boolean(BooleanTree1,InitialEnv,false).
eval_boolean1_expr(tree(boolexp,[_,token(_AND,'and'),BooleanTree2]), InitialEnv, false):-
    eval_boolean(BooleanTree2,InitialEnv,false).
eval_boolean1_expr(X, InitialEnv, false):- eval_boolean2_expr(X, InitialEnv, false).

eval_boolean2_expr(tree(boolexp,[token(_NOT,'not'),BooleanTree]), InitialEnv, false):-
    eval_boolean(BooleanTree,InitialEnv,true).
eval_boolean2_expr(tree(boolexp,[token(_NOT,'not'),BooleanTree]), InitialEnv, true):-
    eval_boolean(BooleanTree,InitialEnv,false).
eval_boolean2_expr(X, InitialEnv, false):- eval_boolean3_expr(X, InitialEnv, false).

eval_boolean3_expr(tree(boolexp,[_,BooleanTree,_]), InitialEnv, Val):-
    eval_boolean(BooleanTree, InitialEnv, Val).
eval_boolean3_expr(tree(boolean,BooleanTree), InitialEnv, Val):-
    eval_boolean(tree(boolean,BooleanTree), InitialEnv, Val).

%%=====All expressions===%%
eval_expr(tree(exp,[StrExprToken]),_InitialEnv,Value):-
    eval_string_expr(StrExprToken, Value).
eval_expr(tree(exp,[BoolExprToken]),InitialEnv,Value):-
    eval_boolean_expr(BoolExprToken, InitialEnv, Value).
eval_expr(tree(exp,[MathExprToken]),InitialEnv,Value):-
    eval_math_expr(MathExprToken, InitialEnv, Value).

%%=====ternary expression===%%
eval_ternary(tree(ter,[BooleanTree,_,ExprTree,_,_]),InitialEnv,Value):-
    eval_boolean(BooleanTree, InitialEnv, true),
    eval_expr(ExprTree,InitialEnv,Value).
eval_ternary(tree(ter,[BooleanTree,_,_,_,ExprTree]),InitialEnv,Value):-
    eval_boolean(BooleanTree, InitialEnv, false),
    eval_expr(ExprTree,InitialEnv,Value).

%%=====Values======%%
eval_values(tree(values,[tree(identifier,[token(_I,Id)])]), Env, Value):-
    lookupEnv(Id,Env,Value).
eval_values(tree(values,[tree(str,[token(_S,Value)])]), _Env, Value).
eval_values(tree(values,[tree(boolean,[token(_,Value)])]), _Env, Value).
eval_values(tree(values,[tree(number,[token(_N,Value)])]), _Env, NewValue):-
    atom_number(Value ,NewValue).
%%======Update Env=======%%
updateEnv(Key,Value,InitialEnv, FinalEnv):-
    select((Key,_),InitialEnv,TempEnv),
    FinalEnv = [(Key,Value)|TempEnv].

updateEnv(Key,Value,InitialEnv, FinalEnv):-
    \+ select((Key,_),InitialEnv,_),
    FinalEnv = [(Key,Value)|InitialEnv].

%%======Lookup Env=======%%
lookupEnv(Key,[],Key):- write(Key), write( not ), write(found).
lookupEnv(Key,[(Key,Value)|_],Value).
lookupEnv(Key,[(K1,_)|T],Value):-
    Key \= K1,
    lookupEnv(Key,T,Value).

%%=============================End of Program======================================%%
