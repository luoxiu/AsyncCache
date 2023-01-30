# AsyncCache

A description of this package.

```
# 63e5ce1e689082ecf09683f2a5ccc7739e84f844

name                  time             std        iterations
------------------------------------------------------------
add LRUCache            1215010.000 ns ±  32.84 %        947
add NSCache             1606702.000 ns ±  23.96 %        796
add YYMemoryCache      16017135.000 ns ±   9.30 %         98
add PINMemoryCache    221014164.500 ns ±  34.96 %         28
get LRUCache             342837.000 ns ±  15.98 %       3588
get NSCache              430409.500 ns ±  12.46 %       3280
get YYMemoryCache        826081.000 ns ±   8.44 %       1667
get PINMemoryCache      2210419.500 ns ±  45.87 %        818
update LRUCache          316364.500 ns ±   8.48 %       4360
update NSCache          1387039.000 ns ±  20.49 %        882
update YYMemoryCache   14827614.000 ns ±   9.25 %         89
update PINMemoryCache 236290582.000 ns ±  27.33 %         20
miss LRUCache            289363.500 ns ±  14.32 %       4744
miss NSCache            1309968.000 ns ±   6.40 %       1075
miss YYMemoryCache       238047.000 ns ±  11.09 %       5877
miss PINMemoryCache      516007.000 ns ±  49.65 %       2647
trim LRUCache           1319463.000 ns ±   9.79 %       1084
trim NSCache            1717314.000 ns ±  22.22 %        801
trim YYMemoryCache    236305015.500 ns ±   9.01 %          6
trim PINMemoryCache   393524538.000 ns ±  44.51 %          4
```
