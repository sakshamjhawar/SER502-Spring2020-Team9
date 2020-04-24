#!/bin/bash
# This is runtime script, takes program file as 1st argument.
#start=$(date +%s)
echo "Compiling..."
echo
sleep 1
output=$(python NovelCLexerParser.py Sample1.nc)
echo "Compilation successful!"
echo
echo "Interpreting..."
echo
sleep 1
#change path according to user
swipl -s /Users/sarang/Downloads/novelC.pl -g "run_program($output), halt."
echo
#duration=$(echo "$(date +%s) - $start" | bc)
#execution_time=`printf "%.8f seconds" $duration`
echo "Done!"
