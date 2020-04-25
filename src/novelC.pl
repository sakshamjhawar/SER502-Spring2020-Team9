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
    FinalEnv = [(Identifier, Val)|InitialEnv].

eval_single_declaration(tree(declaration,[token(_STRING,'string'),token(_I,Identifier),_,token(_S,Val)]), InitialEnv, FinalEnv):-
    FinalEnv = [(Identifier, Val)|InitialEnv].

eval_single_declaration(tree(declaration,[token(_BOOL,'bool'),token(_I,Identifier),_,token(_TRUE,Val)]), InitialEnv, FinalEnv):-
    FinalEnv = [(Identifier, Val)|InitialEnv].

eval_single_declaration(tree(declaration,[token(_INT,'int'),token(_I,Identifier)]), InitialEnv, FinalEnv):-
    FinalEnv = [(Identifier, 0)|InitialEnv].

eval_single_declaration(tree(declaration,[token(_STRING,'string'),token(_I,Identifier)]), InitialEnv, FinalEnv):-
    FinalEnv = [(Identifier, "")|InitialEnv].

eval_single_declaration(tree(declaration,[token(_BOOL,'bool'),token(_I,Identifier)]), InitialEnv, FinalEnv):-
    FinalEnv = [(Identifier, true)|InitialEnv].

%%=====Commands======%%
eval_commands(tree(commands,[SingleCommand]), InitialEnv, FinalEnv):-
    eval_single_command(SingleCommand, InitialEnv, FinalEnv).

eval_commands(tree(commands,[FirstCommand|RemCommand]), InitialEnv, FinalEnv):-
    RemCommand \= [],
    eval_single_command(FirstCommand, InitialEnv, TempEnv),
    eval_commands(tree(commands,RemCommand), TempEnv, FinalEnv).

%%=====Command If-Else======%%
eval_single_command(tree(command,[token(_IF,'if'),_,BooleanTree,_,_,CommandsTree1,_,_,_,_,_,_,_]),  InitialEnv, FinalEnv).

%%=====Command While======%%
eval_single_command(tree(command,[token(_WHILE,'while'),_,BooleanTree,_,_,CommandsTree,_,_]),  InitialEnv, FinalEnv).

%%=====Command Do-While======%%
eval_single_command(tree(command,[token(_DO,'do'),_,CommandsTree,_,_,_,BooleanTree,_,_]),  InitialEnv, FinalEnv).

%%========Traditional For-Loop=========%%
eval_single_command(tree(command,[token(_FOR,'for'),_,_,I,_,N,_,BooleanTree,_,UpdateTree,_,_,CommandsTree,_,_]),  InitialEnv, FinalEnv).

%%========For-Range Loop=========%%
eval_single_command(tree(command,[token(_FOR,'for'),token(_I,I),_,_,_,token(_N,N1),,_,token(_N,N2),,_,_,CommandsTree,_,_]), InitialEnv, FinalEnv).

%%======= I = Exp =========%%
eval_single_command(tree(command,[token(_I,I),_,ExpressionTree,_]), InitialEnv, FinalEnv).