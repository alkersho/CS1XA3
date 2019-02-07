#!bin/bash
if [[ -f todo.log ]]; then
  rm todo.log
fi
cd ../
todo_log=$(grep -ir "#TODO" .)
echo $todo_log >> Project01/todo.log
