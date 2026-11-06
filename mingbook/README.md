# MingBook：克制、轻量的 LaTeX 书籍模板

设计思路参考 ElegantBook（选项切换主题、tcolorbox 定理盒子、书籍结构环境），代码重新编写。

## 文件
- `mingbook.cls`：类文件（唯一必需）
- `mingbook-cn.tex`：中文说明兼示例
- `reference.bib`：示例参考文献
- `build.lua`、`testfiles/`：l3build 回归测试
- `CHANGELOG.md`：更新日志

示例 PDF 由 GitHub Actions 自动编译，在每次运行的 Artifacts 里下载（mingbook-cn-pdf）。

## 编译
需要 XeLaTeX 或 LuaLaTeX（TeX Live 2023+），参考文献用 biber：

    latexmk -xelatex mingbook-cn.tex

## 类选项
| 选项 | 可选值（首个为默认） |
|---|---|
| lang | cn, en |
| theme | blue, green, red, purple, gray |
| thmstyle | fancy, frame, plain |
| latinfont | termes, lm |
| cjkfont | auto, fandol, noto, none |
| layout | a4, b5, pad |
| twoside | false, true |
| answer | true, false |
| thmnum | chapter, section |
| thmcounter | separate, shared |
| chapnum | arabic, chinese |
| bibstyle | 中文默认 gb7714-2015，英文默认 numeric-comp，可设为任意 biblatex 样式 |

## 环境
- 定理族：theorem, lemma, corollary, proposition；定义族：definition, axiom；例题族：example, exercise（均有星号版本，`[标题]` + `\label`）
- proof, solution（受 answer 控制）, remark, note
- introduction（本章导读）, summary（本章小结）, problemset（章末习题，进目录和页眉）
- `\NewTheorem{环境名}{显示名}[thm|def|ex]` 自定义新环境
- `code` 代码环境：`\begin{code}[language=Python, numbers=left][title=标题]`

## 命令
- `\cref{标签}`：智能引用，自动带上“定理”“图”“式”等名称
- `\mingfootermark{内容}`：页脚左下角的签名或版权声明

## 维护

修改 `mingbook.cls` 后的流程：

1. 运行回归测试：`l3build check`（在 `mingbook/` 目录下）。
2. 如果某个测试的输出变化是预期的，确认后用 `l3build save 测试名` 更新基准文件 `testfiles/测试名.tlg`。
3. 新功能或修过的 bug，在 `testfiles/` 里加一个 `.lvt` 测试，写法参照已有文件：
   `\documentclass` 之后 `\input{mingtest}`，在 `\setbox0=\vbox{...}` 里排版，用 `\REC`、`\RECTEXT`、`\RECREF`、`\RECCREF` 记录要比对的结果（说明见 `testfiles/support/mingtest.tex`）。测试会在 XeLaTeX 和 LuaLaTeX 下各跑一遍。
4. 在 `CHANGELOG.md` 的 “未发布” 下记录改动。
5. 提交 PR，GitHub Actions 会在完整 TeX Live 下自动跑测试并编译示例 PDF。

## 许可
LPPL 1.3c
