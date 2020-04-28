#!/bin/bash
# This is runtime script, takes program file as 1st argument.
#start=$(date +%s)
echo "Compiling..."
echo
output=$(python NovelCLexerParser.py $1)
echo "Compilation successful!"
echo
echo "Interpreting..."
echo
swipl -s novelC.pl -g "run_program($output), halt."
echo
#duration=$(echo "$(date +%s) - $start" | bc)
#execution_time=`printf "%.8f seconds" $duration`
echo "Done!"
