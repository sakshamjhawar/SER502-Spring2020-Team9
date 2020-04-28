#!/bin/bash
# This is runtime script, takes program file as 1st argument.
# author: saksham jhawar
# version 1.0
# date 04-24-2020

echo "Compiling..."
echo
output=$(python NovelCLexerParser.py $1)
echo "Compilation successful!"
echo
echo "Interpreting..."
echo
Sleep 1
echo "-------------------------------------------------------"
echo "Sample Program"
echo "-------------------------------------------------------"
swipl -s novelC.pl -g "run_program($output), halt."
echo
echo "Done!"