#!/usr/bin/expect

eval spawn bash

send "julia\r"

expect "julia>"

send "]activate .\r"

expect "pkg>"

send "\010"

send "using Franklin; serve()\r"

interact
