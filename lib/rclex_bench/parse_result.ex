defmodule RclexBench.ParseResult do
    # parse string when string is number
    # when string is not number, return 0
    def parse_number(str) do
        if(String.match?(str, ~r/[[:alpha:]]+/) || str == "") do
            0
        else
            String.to_integer(str)
        end
    end

    # parse time.csv
    def parse_time_by_specifying_char_length(type_name, multi_node, char_length) do
        node_nums = [20,40,60,80,100]
        versions = ["0.4.1", "latest"]
        File.write("results/#{type_name}/#{multi_node}/time_char_#{char_length}.csv", ",")
        Enum.map(versions, fn version -> File.write("results/#{type_name}/#{multi_node}/time_char_#{char_length}.csv", "#{version},", [:append]) end)
        File.write("results/#{type_name}/#{multi_node}/time_char_#{char_length}.csv", "\n", [:append])
        Enum.map(node_nums, fn node_num ->
            File.write("results/#{type_name}/#{multi_node}/time_char_#{char_length}.csv", "#{node_num},", [:append])
            Enum.map(versions, fn version -> 
                {:ok, txt} = File.read("results/#{type_name}/#{multi_node}/#{version}/#{char_length}/#{node_num}/time.csv")
                splitted_txt= Regex.replace(~r/\r\n/, txt, ",")
                |> String.split(",")
                total_sum = splitted_txt
                |> Enum.reduce(fn x, acc ->
                    "#{parse_number(x) + parse_number(acc)}"                    
                end)
                |> String.to_integer()
                
                message_count = splitted_txt
                |> Enum.map(fn x ->
                    if String.match?(x, ~r/^[[:alpha:]]+/) do 0 else 1 end                
                end) 
                |> Enum.reduce(fn x, acc ->
                    x + acc
                end)
                average = round(total_sum / message_count)
                File.write("results/#{type_name}/#{multi_node}/time_char_#{char_length}.csv", "#{average},", [:append])
            end)
            File.write("results/#{type_name}/#{multi_node}/time_char_#{char_length}.csv", "\n", [:append])
        end)
    end

    # parse time.csv
    def parse_time_p1s1(type_name) do
        node_num = 1
        char_lengths = [32, 64, 128, 256]
        versions = ["0.4.1", "latest"]
        File.write("results/#{type_name}/p1s1/time_node_#{node_num}.csv", ",")
        Enum.map(versions, fn version -> File.write("results/#{type_name}/p1s1/time_node_#{node_num}.csv", "#{version},", [:append]) end)
        File.write("results/#{type_name}/p1s1/time_node_#{node_num}.csv", "\n", [:append])
        Enum.map(char_lengths, fn char_length ->
            File.write("results/#{type_name}/p1s1/time_node_#{node_num}.csv", "#{node_num},", [:append])
            Enum.map(versions, fn version -> 
                {:ok, txt} = File.read("results/#{type_name}/p1s1/#{version}/#{char_length}/time.csv")
                splitted_txt= Regex.replace(~r/\r\n/, txt, ",")
                |> String.split(",")
                total_sum = splitted_txt
                |> Enum.reduce(fn x, acc ->
                    "#{parse_number(x) + parse_number(acc)}"                    
                end)
                |> String.to_integer()
                
                message_count = splitted_txt
                |> Enum.map(fn x ->
                    if String.match?(x, ~r/^[[:alpha:]]+/) do 0 else 1 end                
                end) 
                |> Enum.reduce(fn x, acc ->
                    x + acc
                end)
                average = round(total_sum / message_count)
                File.write("results/#{type_name}/p1s1/time_node_#{node_num}.csv", "#{average},", [:append])
            end)
            File.write("results/#{type_name}/p1s1/time_node_#{node_num}.csv", "\n", [:append])
        end)
    end

    def parse_usage(type_name, multi_node, char_length) do
        File.write("results/#{type_name}/#{multi_node}/memory_#{char_length}.csv", ",0.4.1,0.5.1,latest,\n")
        File.write("results/#{type_name}/#{multi_node}/cpu_#{char_length}.csv", ",0.4.1,0.5.1,latest,\n")
        [20,40,60,80,100]
        |> Enum.map(fn node_num ->
            File.write("results/#{type_name}/#{multi_node}/cpu_#{char_length}.csv", "#{node_num},", [:append])
            File.write("results/#{type_name}/#{multi_node}/memory_#{char_length}.csv", "#{node_num},", [:append])
            ["0.4.1","0.5.1","latest"]
            |> Enum.map(fn version -> 
                {:ok, txt} = File.read("results/#{type_name}/#{multi_node}/#{version}_cpu/#{char_length}/#{node_num}/parsed_cpu_usage_#{char_length}_strings.log")
                #calc cpu usage
                cpu_txt = Regex.run(~r/Average: +all +.+/, txt)
                cpu_array = ~w/#{cpu_txt}/
                #IO.inspect(Enum.at(cpu_array,7))
                idle = String.to_float(Enum.at(cpu_array,7))
                diff = 100.0 -  idle
                File.write("results/#{type_name}/#{multi_node}/cpu_#{char_length}.csv", "#{diff},", [:append])
                # calc memory usage
                {:ok, txt2} = File.read("results/#{type_name}/#{multi_node}/#{version}_cpu/#{char_length}/#{node_num}/parsed_memory_usage_#{char_length}_strings.log")
                memory_txt = Regex.run(~r/Average: +[0-9]+ +.+/, txt2)
                memory_array = ~w/#{memory_txt}/
                {:ok, before_txt} = File.read("results/#{type_name}/#{multi_node}/#{version}_cpu/#{char_length}/#{node_num}/parsed_before_memory_usage_#{char_length}_strings.log")
                before_memory_txt = Regex.run(~r/Average: +[0-9]+ +.+/, before_txt)
                before_memory_array = ~w/#{before_memory_txt}/
                used_memory = String.to_integer(Enum.at(memory_array,3)) - String.to_integer(Enum.at(before_memory_array,3)) #- (String.to_integer(Enum.at(memory_array,5)) + String.to_integer(Enum.at(memory_array,6)))
                File.write("results/#{type_name}/#{multi_node}/memory_#{char_length}.csv", "#{used_memory},", [:append])
            end)
            File.write("results/#{type_name}/#{multi_node}/cpu_#{char_length}.csv", "\n", [:append])
            File.write("results/#{type_name}/#{multi_node}/memory_#{char_length}.csv", "\n", [:append])
        end)        
    end
end