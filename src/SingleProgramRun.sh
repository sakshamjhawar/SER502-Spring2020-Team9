#!/bin/bash
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