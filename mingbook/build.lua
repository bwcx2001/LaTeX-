-- l3build 配置：在 mingbook/ 目录下运行
--   l3build check   运行回归测试
--   l3build save X  测试 X 的输出确认无误后，更新基准 .tlg
module       = "mingbook"
sourcefiles  = {"*.cls"}
installfiles = {"*.cls"}
checkengines = {"xetex"}
stdengine    = "xetex"
checkruns    = 1
