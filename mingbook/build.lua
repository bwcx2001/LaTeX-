-- l3build 配置：在 mingbook/ 目录下运行
--   l3build check   运行回归测试
--   l3build save X  测试 X 的输出确认无误后，更新基准 .tlg
module       = "mingbook"
sourcefiles  = {"*.cls"}
installfiles = {"*.cls"}
checkengines = {"xetex"}
stdengine    = "xetex"
checkruns    = 1

-- CI 的 TeX Live 镜像基于 Alpine，自带的 BusyBox diff 不支持 l3build 默认的
-- "diff -c --strip-trailing-cr"，这里改用两边都支持的统一格式
diffexe      = "diff -u"
