#!/bin/bash
mix run -e 'RclexBench.ParseResult.parse_time_by_node_num("string","p1sN",32)'
mix run -e 'RclexBench.ParseResult.parse_time_by_node_num("string","p1sN",256)'
mix run -e 'RclexBench.ParseResult.parse_time_by_node_num("string","pNs1",32)'
mix run -e 'RclexBench.ParseResult.parse_time_by_node_num("string","pNs1",256)'

mix run -e 'RclexBench.ParseResult.parse_time_p1s1("string")'

mix run -e 'RclexBench.ParseResult.parse_usage("string","pNs1",128)'
mix run -e 'RclexBench.ParseResult.parse_usage("string","pNs1",256)'
mix run -e 'RclexBench.ParseResult.parse_usage("string","p1sN",128)'
mix run -e 'RclexBench.ParseResult.parse_usage("string","p1sN",256)'