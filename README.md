# RclexBench

## Usage

1. Edit the version in `mix.exs` as you want to evaluate.
    ```
    defp deps do
      [
        # {:rclex, "~> 0.5.1"}
        {:rclex, path: "../rclex"}
      ]
    end
    ```
1. Run the script. You need to add the version name as the argument
    ```
    $ ./scripts/string_topic.sh 0.5.1
    ```

## Results

- Directory structure
  - `./results/string/p1s1/<version_name>`: pub1-sub1 communication
    - `(cont.)/<length>`: The length of string, a.k.a the size of message
  - `./results/string/p1sN/<version_name>`: pub1-subN communication
    - `(cont.)/<length>/<node>`: The number of nodes
  - `./results/string/pNs1/<version_name>`: pubN-sub1 communication
    - `(cont.)/<length>/<node>`: The number of nodes
- Files
  - `pub.csv`, `sub.csv`: 
    - Raw data for each measurement per line
    - Format: `"{published,subscribed}_message","time"`
  - `time.csv`: 
    - Interval from sub_time to pub_time for the same message
    - Format: `"message"{,"diff_time"}*`

## Configuration point

./lib/rclex_bench.ex
```
  # macro definitions for evaluation
  defmacro eval_interval, do: 100
  defmacro eval_pub_period, do: 1_000
  defmacro eval_sub_period, do: 5_000
  defmacro logger_level, do: :warn
```

./scripts/string_topic.sh
```
### Configuration part.
# The number of communication (publication) for each measurement.
NUM_COMM=5
# Time to sleep after running sub_main before running pub_main.
SUB_PUB_INTERVAL=0.1

# Maximum length of string a.k.a size of message.
MAX_STR_LENGTH=8192
# Initial value of length, that will be increased by a factor of two.
INI_STR_LENGTH=16
# Maximum number of nodes
MAX_NUM_NODES=100
# Initial number of nodes, that will be increased by 20
INI_NUM_NODES=20
```

