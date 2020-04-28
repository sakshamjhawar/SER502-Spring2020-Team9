#!/bin/bash
echo "Compiling..."
echo
output1=$(python NovelCLexerParser.py ../data/constraints13.nc)
output2=$(python NovelCLexerParser.py ../data/factorial.nc)
output3=$(python NovelCLexerParser.py ../data/fibonacci.nc)
output4=$(python NovelCLexerParser.py ../data/sum20num.nc)
output5=$(python NovelCLexerParser.py ../data/compare2num.nc)
echo "Compilation successful!"
echo
echo "Interpreting..."
echo
Sleep 1
echo "-------------------------------------------------------"
echo "Contraints13 Program"
echo "-------------------------------------------------------"
swipl -s novelC.pl -g "run_program($output1), halt."
echo
sleep 1
echo "-------------------------------------------------------"
echo "Factorial Program"
echo "-------------------------------------------------------"
swipl -s novelC.pl -g "run_program($output2), halt."
echo
sleep 1
echo "-------------------------------------------------------"
echo "Fibonacci Program"
echo "-------------------------------------------------------"
swipl -s novelC.pl -g "run_program($output3), halt."
echo
sleep 1
echo "-------------------------------------------------------"
echo "Sum of 20 Numbers Program"
echo "-------------------------------------------------------"
swipl -s novelC.pl -g "run_program($output4), halt."
echo
sleep 1
echo "-------------------------------------------------------"
echo "Compare 2 Numbers Program(n=5, m=5)"
echo "-------------------------------------------------------"
swipl -s novelC.pl -g "run_program($output5), halt."

echo "-------------------------------------------------------"
sleep 1
echo "Done!"