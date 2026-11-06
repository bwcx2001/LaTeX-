# 更新日志

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循语义化版本。
每次修改 `mingbook.cls` 时，在 “未发布” 下记一笔；发布时把它改成版本号和日期，
并同步更新 `mingbook.cls` 里 `\ProvidesClass` 的日期和版本。

## [未发布]

### 新增
- 类选项 `cover=print`：浅色封面，只用细线和浅灰函数线描，没有大面积色块，适合黑白打印。默认 `cover=band` 与原来相同。

## [0.2.0] - 2026-11-06

### 新增
- `code` 代码环境（tcolorbox + listings），两个可选参数分别是 listings 选项和盒子选项；`\lstinline` 行内代码。
- 接入 cleveref：`\cref` 自动带上“定理”“图”“式”“第 X 章”等名称，中文连接词为“和”“、”“至”。
- `\mingfootermark{内容}`：在页脚左下角放签名或版权声明，示例文档用它放了签名水印。

### 变更
- `lang=cn` 时参考文献默认样式改为 `gb7714-2015`（英文仍为 `numeric-comp`），可用 `bibstyle=` 覆盖。
- 回归测试同时在 XeLaTeX 和 LuaLaTeX 下运行；名称、章标签类测试只比对纯文字；测试公共代码移到 `testfiles/support/mingtest.tex`。
- CI 额外用 LuaLaTeX 编译示例文档。

### 修复
- 定理类环境内的 `\label` 原来记录的是所在节的编号（例如节 1.3 里的定理 1.1 被引用成 1.3），现在指向环境自身的编号。
- 封面不再生成与正文第 1 页重名的 PDF 页面锚点。

## [0.1.0] - 2026-11-06

### 新增
- 第一个版本：类选项 lang、theme、thmstyle、latinfont、cjkfont、layout、twoside、
  answer、thmnum、thmcounter、chapnum、bibstyle。
- 定理类环境（theorem、lemma、corollary、proposition、definition、axiom、
  example、exercise）及其星号版本，`\NewTheorem` 自定义接口。
- proof、solution、remark、note、introduction、summary、problemset 环境。
- 封面 `\maketitle`，支持 `\subtitle`、`\institute`、`\version`、`\extrainfo`、
  `\coverimage`、`\logo`。
- l3build 回归测试与 GitHub Actions 自动测试、编译示例 PDF。
