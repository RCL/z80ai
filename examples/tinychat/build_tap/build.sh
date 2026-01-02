#!/bin/sh
rm -f tiny_chat.tap main_code.tap

sjasmplus ./code/main.asm

cat basic\basic_part.tap > tiny_chat.tap
cat main_code.tap >> tiny_chat.tap

rm -f main_code.tap
