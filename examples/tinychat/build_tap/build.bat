@echo off
del /Q tiny_chat.tap main_code.tap
sjasmplus code\main.asm

copy /B basic\basic_part.tap + main_code.tap tiny_chat.tap
del /Q main_code.tap
