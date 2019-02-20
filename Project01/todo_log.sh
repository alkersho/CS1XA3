#!bin/bash

cd ../
todo_log=$(grep -ir "#TODO" .)
echo $todo_log > Project01/todo.log
