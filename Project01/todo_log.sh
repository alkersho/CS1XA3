#!bin/bash
# finds all locations where '#TODO' mentioned and outputs all lines into todo.log file
cd ../
todo_log=$(grep -ir "#TODO" .)
echo $todo_log > Project01/todo.log
