#!/usr/bin/env bash
#
# Generates kinda meaningful seed.

word="$1"

declare -A numbers_to_letters

numbers_to_letters["q"]=1
numbers_to_letters["a"]=1
numbers_to_letters["z"]=1
numbers_to_letters["w"]=2
numbers_to_letters["s"]=2
numbers_to_letters["x"]=2
numbers_to_letters["e"]=3
numbers_to_letters["d"]=3
numbers_to_letters["c"]=3
numbers_to_letters["r"]=4
numbers_to_letters["f"]=4
numbers_to_letters["v"]=4
numbers_to_letters["t"]=5
numbers_to_letters["g"]=5
numbers_to_letters["b"]=5
numbers_to_letters["y"]=6
numbers_to_letters["h"]=6
numbers_to_letters["n"]=6
numbers_to_letters["u"]=7
numbers_to_letters["j"]=7
numbers_to_letters["m"]=7
numbers_to_letters["i"]=8
numbers_to_letters["k"]=8
numbers_to_letters["o"]=9
numbers_to_letters["l"]=9
numbers_to_letters["p"]=9

seed=""

for (( i=0; i<${#word}; i++ )); do
  char="${word:$i:1}"
  digit="${numbers_to_letters["${char}"]}"
  seed+="${digit}"
done

echo "${seed}"
