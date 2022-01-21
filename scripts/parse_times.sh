#!/bin/bash
mix run -e 'RclexBench.ParseResult.parse_time("string","p1sN")'
mix run -e 'RclexBench.ParseResult.parse_time("string","p1sN")'
mix run -e 'RclexBench.ParseResult.parse_time("string","pNs1")'
mix run -e 'RclexBench.ParseResult.parse_time("string","pNs1")'

mix run -e 'RclexBench.ParseResult.parse_time_p1s1("string")'