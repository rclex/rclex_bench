#!/bin/bash
# mix run -e 'RclexBench.ParseResult.parse_usage_p1s1("string",128)'
# mix run -e 'RclexBench.ParseResult.parse_usage_p1s1("string",256)'
mix run -e 'RclexBench.ParseResult.parse_usage("string","pNs1")'
mix run -e 'RclexBench.ParseResult.parse_usage("string","p1sN")'