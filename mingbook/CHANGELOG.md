# 更新日志

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循语义化版本。
每次修改 `mingbook.cls` 时，在 “未发布” 下记一笔；发布时把它改成版本号和日期，
并同步更新 `mingbook.cls` 里 `\ProvidesClass` 的日期和版本。

## [未发布]

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
