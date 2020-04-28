#!/bin/bash
# This is runtime script, takes program file as 1st argument.
# author: saksham jhawar
# version 1.0
# date 04-24-2020
#start=$(date +%s)
echo "Compiling..."
echo
output1=$(python NovelCLexerParser.py ../data/constraints13.nc)
output2=$(python NovelCLexerParser.py ../data/factorail.nc)
output3=$(python NovelCLexerParser.py ../data/fibonacci.nc)
output4=$(python NovelCLexerParser.py ../data/sum20num.nc)
echo "Compilation successful!"
echo
echo "Interpreting..."
echo
echo "contraints 1-3"
swipl -s novelC.pl -g "run_program($output1), halt."
echo "-------------------------------------------------------"
echo "factorail"
swipl -s novelC.pl -g "run_program($output2), halt."
echo "-------------------------------------------------------"
echo "fibonacci"
swipl -s novelC.pl -g "run_program($output3), halt."
echo "-------------------------------------------------------"
echo "sum20num"
swipl -s novelC.pl -g "run_program($output4), halt."
echo "-------------------------------------------------------"
sleep 20
echo
#duration=$(echo "$(date +%s) - $start" | bc)
#execution_time=`printf "%.8f seconds" $duration`
echo "Done!"
