% -----------------------------------------------------------------------------
% mingbook.cls  ——  MingBook：一个克制、轻量的中英文书籍模板
%
% 设计思路参考 ElegantBook（选项切换主题 + tcolorbox 定理盒子 + 书籍结构环境），
% 代码为重新编写：用 l3keys 处理选项，只加载真正用到的宏包，所有颜色和名称都可在
% 导言区覆盖。
%
% 编译：XeLaTeX 或 LuaLaTeX（推荐 latexmk -xelatex），参考文献用 biber。
% 许可：LPPL 1.3c
% -----------------------------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}[2022/06/01]
\ProvidesClass{mingbook}[2026/11/06 v0.2.0 MingBook book class]

\RequirePackage{iftex}
\ifPDFTeX
  \ClassError{mingbook}
    {MingBook needs XeLaTeX or LuaLaTeX}
    {Please compile with xelatex or lualatex (e.g. latexmk -xelatex).}
\fi

% =============================================================================
% 1. 类选项
% =============================================================================
\ExplSyntaxOn
\tl_new:N \g__ming_lang_tl
\tl_new:N \g__ming_theme_tl
\tl_new:N \g__ming_style_tl
\tl_new:N \g__ming_font_tl
\tl_new:N \g__ming_cjkfont_tl
\tl_new:N \g__ming_paper_tl
\tl_new:N \g__ming_thmnum_tl
\tl_new:N \g__ming_bibstyle_tl
\bool_new:N \g__ming_twoside_bool
\bool_new:N \g__ming_answer_bool
\bool_new:N \g__ming_shared_bool
\bool_new:N \g__ming_zhchap_bool
\bool_new:N \g__ming_printcover_bool

\keys_define:nn { mingbook }
  {
    lang     .choices:nn = { cn, en }
      { \tl_gset_eq:NN \g__ming_lang_tl \l_keys_choice_tl },
    lang     .initial:n  = cn,
    theme    .choices:nn = { blue, green, red, purple, gray }
      { \tl_gset_eq:NN \g__ming_theme_tl \l_keys_choice_tl },
    theme    .initial:n  = blue,
    thmstyle .choices:nn = { fancy, frame, plain }
      { \tl_gset_eq:NN \g__ming_style_tl \l_keys_choice_tl },
    thmstyle .initial:n  = fancy,
    latinfont .choices:nn = { termes, lm }
      { \tl_gset_eq:NN \g__ming_font_tl \l_keys_choice_tl },
    latinfont .initial:n  = termes,
    cjkfont  .choices:nn = { auto, fandol, noto, none }
      { \tl_gset_eq:NN \g__ming_cjkfont_tl \l_keys_choice_tl },
    cjkfont  .initial:n  = auto,
    layout   .choices:nn = { a4, b5, pad }
      { \tl_gset_eq:NN \g__ming_paper_tl \l_keys_choice_tl },
    layout   .initial:n  = a4,
    thmnum   .choices:nn = { chapter, section }
      { \tl_gset_eq:NN \g__ming_thmnum_tl \l_keys_choice_tl },
    thmnum   .initial:n  = chapter,
    bibstyle .tl_gset:N  = \g__ming_bibstyle_tl,
    twoside  .bool_gset:N = \g__ming_twoside_bool,
    twoside  .default:n  = true,
    answer   .bool_gset:N = \g__ming_answer_bool,
    answer   .initial:n  = true,
    answer   .default:n  = true,
    thmcounter .choices:nn = { separate, shared }
      { \bool_gset:Nn \g__ming_shared_bool { \int_compare_p:n { \l_keys_choice_int = 2 } } },
    chapnum  .choices:nn = { arabic, chinese }
      { \bool_gset:Nn \g__ming_zhchap_bool { \int_compare_p:n { \l_keys_choice_int = 2 } } },
    % 封面：band 为上半部色块；print 为浅色线描，适合黑白打印
    cover    .choices:nn = { band, print }
      { \bool_gset:Nn \g__ming_printcover_bool { \int_compare_p:n { \l_keys_choice_int = 2 } } },
    % 其他选项（如 11pt、openany）原样交给 book 类
    unknown  .code:n = { \PassOptionsToClass { \l_keys_key_str } { book } }
  }
\ProcessKeyOptions [ mingbook ]

% 供后文 LaTeX2e 代码使用的判断
\cs_new:Npn \ming@ifcn #1#2 { \str_if_eq:VnTF \g__ming_lang_tl { cn } {#1} {#2} }
\cs_new:Npn \ming@ifstyle #1#2#3 { \str_if_eq:VnTF \g__ming_style_tl {#1} {#2} {#3} }
\cs_new:Npn \ming@ifanswer #1#2 { \bool_if:NTF \g__ming_answer_bool {#1} {#2} }
\cs_new:Npn \ming@ifshared #1#2 { \bool_if:NTF \g__ming_shared_bool {#1} {#2} }
\cs_new:Npn \ming@ifzhchap #1#2 { \bool_if:NTF \g__ming_zhchap_bool {#1} {#2} }
\cs_new:Npn \ming@ifprintcover #1#2 { \bool_if:NTF \g__ming_printcover_bool {#1} {#2} }
\cs_new:Npn \ming@thmwithin { \tl_use:N \g__ming_thmnum_tl }
% 参考文献样式：未指定时，中文用国标 gb7714-2015，英文用 numeric-comp
\cs_new:Npn \ming@bibstyle
  {
    \tl_if_empty:NTF \g__ming_bibstyle_tl
      { \str_if_eq:VnTF \g__ming_lang_tl { cn } { gb7714-2015 } { numeric-comp } }
      { \tl_use:N \g__ming_bibstyle_tl }
  }

\bool_if:NTF \g__ming_twoside_bool
  { \PassOptionsToClass { twoside } { book } }
  { \PassOptionsToClass { oneside, openany } { book } }
\ExplSyntaxOff

\LoadClass{book}

% =============================================================================
% 2. 版面
% =============================================================================
\RequirePackage{geometry}
\ExplSyntaxOn
\str_case:Vn \g__ming_paper_tl
  {
    { a4 }  { \geometry { a4paper, top = 27mm, bottom = 25mm,
                          inner = 25mm, outer = 25mm,
                          headheight = 15pt, headsep = 8mm, footskip = 12mm } }
    { b5 }  { \geometry { b5paper, top = 22mm, bottom = 22mm,
                          inner = 20mm, outer = 20mm,
                          headheight = 15pt, headsep = 6mm, footskip = 10mm } }
    { pad } { \geometry { paperwidth = 7.5in, paperheight = 10in,
                          margin = 15mm, top = 20mm,
                          headheight = 15pt, headsep = 5mm, footskip = 8mm } }
  }
\ExplSyntaxOff

% =============================================================================
% 3. 颜色主题
%   ming-main   结构色：标题、页眉、定理类
%   ming-second 强调色：例题、练习、注
%   ming-third  辅助色：定义、公理
%   导言区可直接 \definecolor{ming-main}{HTML}{...} 覆盖
% =============================================================================
\RequirePackage{xcolor}
\ExplSyntaxOn
\str_case:Vn \g__ming_theme_tl
  {
    { blue }   { \definecolor{ming-main}{HTML}{1F4E79}
                 \definecolor{ming-second}{HTML}{B4532A}
                 \definecolor{ming-third}{HTML}{2A7468} }
    { green }  { \definecolor{ming-main}{HTML}{2D6A4F}
                 \definecolor{ming-second}{HTML}{9C6114}
                 \definecolor{ming-third}{HTML}{3A5F8F} }
    { red }    { \definecolor{ming-main}{HTML}{8E2C2C}
                 \definecolor{ming-second}{HTML}{2F5D8A}
                 \definecolor{ming-third}{HTML}{6B5B2E} }
    { purple } { \definecolor{ming-main}{HTML}{4B3B7A}
                 \definecolor{ming-second}{HTML}{A0522D}
                 \definecolor{ming-third}{HTML}{2A7468} }
    { gray }   { \definecolor{ming-main}{HTML}{2B2B2B}
                 \definecolor{ming-second}{HTML}{555555}
                 \definecolor{ming-third}{HTML}{444444} }
  }
\ExplSyntaxOff
\definecolor{ming-gray}{HTML}{6B6B6B}

% =============================================================================
% 4. 字体
% =============================================================================
\RequirePackage{amsmath}
\ExplSyntaxOn
\str_if_eq:VnT \g__ming_lang_tl { cn }
  {
    \str_case:Vn \g__ming_cjkfont_tl
      {
        { auto }   { \RequirePackage [ UTF8, scheme = plain ] { ctex } }
        { fandol } { \RequirePackage [ UTF8, scheme = plain, fontset = fandol ] { ctex } }
        { noto }   { \RequirePackage [ UTF8, scheme = plain, fontset = none ] { ctex }
                     \setCJKmainfont { Noto~Serif~CJK~SC } [ BoldFont = *~Bold ]
                     \setCJKsansfont { Noto~Sans~CJK~SC } [ BoldFont = *~Bold ]
                     \setCJKmonofont { Noto~Sans~Mono~CJK~SC }
                     \setCJKfamilyfont { zhsong } { Noto~Serif~CJK~SC }
                     \setCJKfamilyfont { zhhei }  { Noto~Sans~CJK~SC }
                     \NewDocumentCommand \songti {} { \CJKfamily { zhsong } }
                     \NewDocumentCommand \heiti {} { \CJKfamily { zhhei } } }
        { none }   { \RequirePackage [ UTF8, scheme = plain, fontset = none ] { ctex } }
      }
  }
\str_if_eq:VnTF \g__ming_font_tl { termes }
  {
    \RequirePackage { unicode-math }
    \setmainfont { texgyretermes }
      [ Extension = .otf, UprightFont = *-regular, BoldFont = *-bold,
        ItalicFont = *-italic, BoldItalicFont = *-bolditalic ]
    \setsansfont { texgyreheros }
      [ Extension = .otf, Scale = 0.9, UprightFont = *-regular, BoldFont = *-bold,
        ItalicFont = *-italic, BoldItalicFont = *-bolditalic ]
    \setmathfont { texgyretermes-math.otf }
  }
  {
    \RequirePackage { amssymb }
    \RequirePackage { fontspec }
  }
\ExplSyntaxOff

% 中文环境下的“引文字体”：有楷体用楷体，否则用斜体
\AtBeginDocument{%
  \ifcsname kaishu\endcsname
    \providecommand\mingquotefont{\kaishu}%
  \else
    \providecommand\mingquotefont{\itshape}%
  \fi}

\ming@ifcn
  {\linespread{1.35}\setlength{\parindent}{2em}}
  {\linespread{1.15}}

% =============================================================================
% 5. 名称（全部是宏，导言区用 \renewcommand 修改即可）
% =============================================================================
\ming@ifcn{%
  \renewcommand\contentsname{目\hspace{1em}录}
  \renewcommand\listfigurename{插图目录}
  \renewcommand\listtablename{表格目录}
  \renewcommand\figurename{图}
  \renewcommand\tablename{表}
  \renewcommand\bibname{参考文献}
  \renewcommand\indexname{索引}
  \renewcommand\appendixname{附录}
  \newcommand\theoremname{定理}
  \newcommand\lemmaname{引理}
  \newcommand\corollaryname{推论}
  \newcommand\propositionname{命题}
  \newcommand\definitionname{定义}
  \newcommand\axiomname{公理}
  \newcommand\examplename{例}
  \newcommand\exercisename{练习}
  \providecommand\proofname{}\renewcommand\proofname{证明}
  \newcommand\solutionname{解}
  \newcommand\remarkname{注}
  \newcommand\notename{笔记}
  \newcommand\introductionname{本章导读}
  \newcommand\summaryname{本章小结}
  \newcommand\problemsetname{习题}
  \newcommand\authorlabel{作者}
  \newcommand\institutelabel{单位}
  \newcommand\datelabel{日期}
  \newcommand\versionlabel{版本}
}{%
  \newcommand\theoremname{Theorem}
  \newcommand\lemmaname{Lemma}
  \newcommand\corollaryname{Corollary}
  \newcommand\propositionname{Proposition}
  \newcommand\definitionname{Definition}
  \newcommand\axiomname{Axiom}
  \newcommand\examplename{Example}
  \newcommand\exercisename{Exercise}
  \providecommand\proofname{}\renewcommand\proofname{Proof}
  \newcommand\solutionname{Solution}
  \newcommand\remarkname{Remark}
  \newcommand\notename{Note}
  \newcommand\introductionname{Chapter Overview}
  \newcommand\summaryname{Summary}
  \newcommand\problemsetname{Problems}
  \newcommand\authorlabel{Author}
  \newcommand\institutelabel{Institute}
  \newcommand\datelabel{Date}
  \newcommand\versionlabel{Version}
}

% =============================================================================
% 6. 章节标题与目录
% =============================================================================
\RequirePackage{titlesec}
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{1}

\newif\ifming@appendix
\g@addto@macro\appendix{\global\ming@appendixtrue}

% 章编号文字：正文 “第 1 章 / 第一章 / Chapter 1”，附录 “附录 A / Appendix A”
\newcommand\ming@chapnumber{%
  \ming@ifzhchap{\zhnumber{\arabic{chapter}}}{\,\thechapter\,}}
\newcommand\mingchapterlabel{%
  \ifming@appendix
    \appendixname~\thechapter
  \else
    \ming@ifcn{第\ming@chapnumber 章}{\chaptername~\thechapter}%
  \fi}

\titleformat{\chapter}[display]
  {\normalfont\sffamily\bfseries\color{ming-main}}
  {\large\mingchapterlabel}
  {8pt}
  {\huge}
  [\vspace{6pt}{\color{ming-main}\titlerule[0.6pt]}]
\titleformat{name=\chapter,numberless}[display]
  {\normalfont\sffamily\bfseries\color{ming-main}}
  {}
  {0pt}
  {\huge}
  [\vspace{6pt}{\color{ming-main}\titlerule[0.6pt]}]
\titlespacing*{\chapter}{0pt}{10pt}{32pt}

\titleformat{\section}
  {\normalfont\sffamily\bfseries\Large\color{ming-main}}
  {\thesection}{0.8em}{}
\titleformat{\subsection}
  {\normalfont\sffamily\bfseries\large\color{ming-main}}
  {\thesubsection}{0.8em}{}
\titleformat{\subsubsection}
  {\normalfont\sffamily\bfseries\normalsize\color{ming-main}}
  {\thesubsubsection}{0.8em}{}
\titlespacing*{\section}{0pt}{3.0ex plus 1ex minus .2ex}{1.6ex plus .2ex}
\titlespacing*{\subsection}{0pt}{2.5ex plus 1ex minus .2ex}{1.2ex plus .2ex}

% 目录：章条目带“第 X 章”，加粗着色
\RequirePackage{titletoc}
\titlecontents{chapter}[0pt]
  {\addvspace{8pt}\sffamily\bfseries\color{ming-main}}
  {\ming@tocchaplabel\quad}
  {}
  {\hfill\contentspage}
\titlecontents{section}[2.2em]
  {\addvspace{1pt}}
  {\contentslabel{2.2em}}
  {}
  {\titlerule*[0.6pc]{.}\contentspage}
\titlecontents{subsection}[5em]
  {}
  {\contentslabel{2.8em}}
  {}
  {\titlerule*[0.6pc]{.}\contentspage}
% 目录中章号显示为“第 1 章 / Chapter 1 / 附录 A”
\newif\ifming@tocappendix
\newcommand\ming@tocchaplabel{%
  \ifming@tocappendix\appendixname~\thecontentslabel
  \else\ming@ifcn{第\ming@ifzhchap{\zhnumber{\thecontentslabel}}{\,\thecontentslabel\,}章}%
                 {\chaptername~\thecontentslabel}\fi}
\g@addto@macro\appendix{%
  \addtocontents{toc}{\protect\ming@tocappendixtrue}}

% =============================================================================
% 7. 页眉页脚
% =============================================================================
\RequirePackage{fancyhdr}
\newcommand\ming@headfont{\normalfont\small\sffamily\color{ming-gray}}
% 页脚左下角的标记（签名、版权声明等），默认为空：
%   \mingfootermark{内容}
\newcommand\ming@footermark{}
\newcommand\mingfootermark[1]{\gdef\ming@footermark{#1}}
\fancyhf{}
\fancyfoot[L]{\ming@footermark}
\ExplSyntaxOn
\bool_if:NTF \g__ming_twoside_bool
  {
    \fancyhead[LE]{\ming@headfont\thepage}
    \fancyhead[RE]{\ming@headfont\leftmark}
    \fancyhead[LO]{\ming@headfont\rightmark}
    \fancyhead[RO]{\ming@headfont\thepage}
  }
  {
    \fancyhead[L]{\ming@headfont\leftmark}
    \fancyhead[R]{\ming@headfont\thepage}
  }
\ExplSyntaxOff
\renewcommand\headrule{{\color{ming-main!60}\hrule\@height0.4pt\@width\headwidth}}
\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyfoot[C]{\ming@headfont\thepage}%
  \fancyfoot[L]{\ming@footermark}%
  \renewcommand\headrule{}}
\pagestyle{fancy}
% fancyhdr 会重设 \chaptermark，因此放在 \pagestyle{fancy} 之后
\renewcommand\chaptermark[1]{%
  \markboth{\ifnum\c@secnumdepth>\m@ne\mingchapterlabel\quad\fi#1}{}}
\renewcommand\sectionmark[1]{\markright{\thesection\quad#1}}

% 空白页不要页眉
\renewcommand\cleardoublepage{\clearpage\if@twoside\ifodd\c@page\else
  \hbox{}\thispagestyle{empty}\newpage\fi\fi}

% =============================================================================
% 8. 列表、图表标题、超链接
% =============================================================================
\RequirePackage{graphicx}
\graphicspath{{./figure/}{./figures/}{./image/}{./images/}}
\RequirePackage{booktabs}
\RequirePackage{multicol}
\RequirePackage{enumitem}
\setlist{itemsep=2pt, topsep=4pt, parsep=0pt}
\setlist[itemize,1]{label=\textcolor{ming-main}{\small\textbullet}}
\setlist[itemize,2]{label=\textcolor{ming-main}{\small\textendash}}
\setlist[enumerate,1]{label=\textcolor{ming-main}{\arabic*.}}
\setlist[enumerate,2]{label=\textcolor{ming-main}{(\alph*)}}

\RequirePackage{caption}
\captionsetup{font=small, labelfont={bf,color=ming-main}, labelsep=quad, skip=6pt}

% =============================================================================
% 8.5 超链接与智能引用
%     \cref{标签} 自动带上“定理”“图”“式”等名称；cleveref 必须在 hyperref 之后
% =============================================================================
\RequirePackage{hyperref}
\hypersetup{
  colorlinks, linkcolor=ming-main, citecolor=ming-second, urlcolor=ming-third,
  bookmarksnumbered, bookmarksopen, unicode, pdfstartview=FitH}
\RequirePackage[noabbrev, nameinlink]{cleveref}
% \ming@crefname{类型}{名称}：为一种引用类型设置名称。
%   中文：单复数相同；英文：cleveref 已有的类型保持原样，新类型复数加 s
\newcommand\ming@crefname[2]{%
  \ming@ifcn
    {\crefname{#1}{#2}{#2}\Crefname{#1}{#2}{#2}}
    {\@ifundefined{cref@#1@name}
       {\crefname{#1}{#2}{#2s}\Crefname{#1}{#2}{#2s}}{}}}
\ming@ifcn{%
  \crefname{figure}{图}{图}\Crefname{figure}{图}{图}
  \crefname{table}{表}{表}\Crefname{table}{表}{表}
  \crefname{equation}{式}{式}\Crefname{equation}{式}{式}
  \crefformat{chapter}{#2第~#1~章#3}\Crefformat{chapter}{#2第~#1~章#3}
  \crefformat{section}{#2第~#1~节#3}\Crefformat{section}{#2第~#1~节#3}
  \crefformat{subsection}{#2第~#1~节#3}\Crefformat{subsection}{#2第~#1~节#3}
  \crefname{appendix}{附录}{附录}\Crefname{appendix}{附录}{附录}
  \crefname{enumi}{}{}\Crefname{enumi}{}{}
  \newcommand\crefpairconjunction{和}
  \newcommand\crefmiddleconjunction{、}
  \newcommand\creflastconjunction{和}
  \newcommand\crefrangeconjunction{至}
  \newcommand\crefpairgroupconjunction{和}
  \newcommand\crefmiddlegroupconjunction{、}
  \newcommand\creflastgroupconjunction{和}
}{}

% =============================================================================
% 9. 定理类环境（tcolorbox）
%    三种外观由 thmstyle 选项切换：
%      fancy  左侧色条 + 浅色底（默认）
%      frame  细边框 + 标题条
%      plain  无装饰，只有彩色标题
% =============================================================================
\RequirePackage[most]{tcolorbox}

\tcbset{
  ming/base/.style={
    enhanced, breakable,
    before skip=10pt plus 2pt, after skip=10pt plus 2pt,
    fonttitle=\sffamily\bfseries,
    parbox=false,
  },
  % 标题跟在正文第一行开头
  ming/inline/.style={
    detach title,
    before upper={\tcbtitle\enspace\ignorespaces},
  },
  ming/fancy/.style={
    ming/base, ming/inline,
    colback=#1!5, colframe=#1, coltitle=#1,
    boxrule=0pt, leftrule=2.4pt, arc=0pt, outer arc=0pt,
    left=9pt, right=9pt, top=6pt, bottom=6pt,
  },
  ming/frame/.style={
    ming/base,
    colback=white, colframe=#1, colbacktitle=#1!12, coltitle=#1,
    boxrule=0.5pt, arc=1.5pt,
    titlerule=0pt, toptitle=2pt, bottomtitle=2pt,
    left=8pt, right=8pt, top=5pt, bottom=6pt,
  },
  ming/plain/.style={
    ming/base, ming/inline, blanker,
    coltitle=#1,
  },
  % 例题、练习：比定理轻一档，只有一条细色线
  ming/light/.style={
    ming/base, ming/inline, blanker,
    coltitle=#1,
    borderline west={0.8pt}{0pt}{#1!70},
    left=8pt,
  },
}

% 让正文里的 \label 指向本盒子的编号，并让 \cref 认出环境类型。
% tcolorbox 把编号写在标题里，标题在另一个盒子中排版，正文中的 \label
% 看不到它；这里在正文开头重新设置引用信息（不再步进计数器、不新建锚点），
% 写法与 cleveref 的 \refstepcounter 相同，只是类型换成环境名。
\newcommand\ming@setlabel[2]{% #1 计数器  #2 环境名（cleveref 类型）
  \protected@edef\@currentlabel{\csname p@#1\endcsname\csname the#1\endcsname}%
  \@ifundefined{theH#1}%
    {\edef\@currentHref{#1.\arabic{#1}}}%
    {\edef\@currentHref{#1.\csname theH#1\endcsname}}%
  % 较新的 LaTeX/cleveref 按 \@currentcounter 和计数器别名确定类型，
  % 旧版本读 \cref@currentlabel，两种都设置
  \def\@currentcounter{#1}%
  \crefalias{#1}{#2}%
  \cref@constructprefix{#1}{\cref@result}%
  \protected@edef\cref@currentlabel{%
    [#2][\arabic{#1}][\cref@result]\csname p@#1\endcsname\csname the#1\endcsname}}
\tcbset{
  ming/label/.style={before upper pre={\ming@setlabel{\tcbcounter}{#1}}},
}

% 当前全局外观
\ming@ifstyle{fancy}{\tcbset{ming/thm/.style={ming/fancy=#1}}}{%
\ming@ifstyle{frame}{\tcbset{ming/thm/.style={ming/frame=#1}}}{%
                     \tcbset{ming/thm/.style={ming/plain=#1}}}}

% 共享计数器：由一个不直接使用的盒子持有，其他环境 use counter from 它
\newtcolorbox[auto counter, number within=\ming@thmwithin]{ming@counterholder}{}

% \ming@newthm{环境名}{名称宏}{颜色}{外观}{计数方式}
%   计数方式：shared 用共享计数器；own 用自己的计数器
\NewDocumentCommand\ming@newthm{ m m m m m }{%
  \ifx\relax#5\relax\def\ming@cnt{own}\else\edef\ming@cnt{#5}\fi
  \def\ming@tmp{shared}%
  \ifx\ming@cnt\ming@tmp
    \DeclareTColorBox[use counter from=ming@counterholder]{#1}{ O{} }{%
      #4={#3}, ming/label={#1},
      title={#2~\thetcbcounter\ifblank{##1}{}{\ (##1)}}}%
  \else
    \DeclareTColorBox[auto counter, number within=\ming@thmwithin]{#1}{ O{} }{%
      #4={#3}, ming/label={#1},
      title={#2~\thetcbcounter\ifblank{##1}{}{\ (##1)}}}%
  \fi
  \DeclareTColorBox{#1*}{ O{} }{%
    #4={#3},
    title={#2\ifblank{##1}{}{\ (##1)}}}%
  \ming@crefname{#1}{#2}%
}
\newcommand\ming@thmcnt{\ming@ifshared{shared}{own}}

% 定理族：结构色
\ming@newthm{theorem}    {\theoremname}    {ming-main} {ming/thm}{\ming@thmcnt}
\ming@newthm{lemma}      {\lemmaname}      {ming-main} {ming/thm}{\ming@thmcnt}
\ming@newthm{corollary}  {\corollaryname}  {ming-main} {ming/thm}{\ming@thmcnt}
\ming@newthm{proposition}{\propositionname}{ming-main} {ming/thm}{\ming@thmcnt}
% 定义族：辅助色
\ming@newthm{definition} {\definitionname} {ming-third}{ming/thm}{\ming@thmcnt}
\ming@newthm{axiom}      {\axiomname}      {ming-third}{ming/thm}{\ming@thmcnt}
% 例题、练习：强调色、轻外观，各自独立编号
\ming@newthm{example}    {\examplename}    {ming-second}{ming/light}{own}
\ming@newthm{exercise}   {\exercisename}   {ming-second}{ming/light}{own}

% 用户接口：\NewTheorem{环境名}{显示名}[族]
%   族：thm（定理色，默认）| def（定义色）| ex（例题色、轻外观）
\NewDocumentCommand\NewTheorem{ m m O{thm} }{%
  \expandafter\def\csname #1name\endcsname{#2}%
  \def\ming@tmp{#3}\def\ming@def{def}\def\ming@ex{ex}%
  \ifx\ming@tmp\ming@def
    \ming@newthm{#1}{\csname #1name\endcsname}{ming-third}{ming/thm}{\ming@thmcnt}%
  \else\ifx\ming@tmp\ming@ex
    \ming@newthm{#1}{\csname #1name\endcsname}{ming-second}{ming/light}{own}%
  \else
    \ming@newthm{#1}{\csname #1name\endcsname}{ming-main}{ming/thm}{\ming@thmcnt}%
  \fi\fi}

% 证明、解答、注
\newcommand\mingqed{{\color{ming-main}\fboxsep=0pt\fboxrule=0.5pt\fbox{\rule{0pt}{0.6em}\hspace{0.6em}}}}
\newenvironment{proof}[1][\proofname]
  {\par\addvspace{4pt}\noindent{\sffamily\bfseries\color{ming-main}#1}\enspace\ignorespaces}
  {\ifhmode\unskip\nobreak\hfill\fi\mingqed\par\addvspace{4pt}}

\ming@ifanswer{%
  \newenvironment{solution}[1][\solutionname]
    {\par\addvspace{4pt}\noindent{\sffamily\bfseries\color{ming-second}#1}\enspace\ignorespaces}
    {\par\addvspace{4pt}}%
}{%
  % answer=false：整段丢弃解答内容
  \NewDocumentEnvironment{solution}{ O{} +b }{}{}%
}

\newenvironment{remark}[1][\remarkname]
  {\par\addvspace{4pt}\noindent{\sffamily\bfseries\color{ming-second}#1}\enspace\ignorespaces}
  {\par\addvspace{4pt}}

\newtcolorbox{note}[1][\notename]{%
  ming/base, ming/inline, blanker,
  coltitle=ming-second,
  title={#1},
  borderline west={0.8pt}{0pt}{ming-second!70}, left=8pt,
  fontupper=\mingquotefont}

% =============================================================================
% 9.5 代码环境
%   \begin{code}[listings 选项][盒子选项] ... \end{code}
%   例：\begin{code}[language=Python, numbers=left][title=快速排序]
%   行内代码：\lstinline|...|
% =============================================================================
\tcbuselibrary{listings}
\lstdefinestyle{ming}{
  basicstyle=\ttfamily\small,
  keywordstyle=\color{ming-main}\bfseries,
  commentstyle=\color{ming-gray},
  stringstyle=\color{ming-second},
  numberstyle=\tiny\color{ming-gray},
  numbersep=8pt,
  columns=fullflexible, keepspaces=true,
  breaklines=true, breakatwhitespace=false,
  showstringspaces=false, tabsize=4,
  upquote=true,
}
\lstset{style=ming}
\tcbset{
  ming/code/.style={
    enhanced, breakable, listing only,
    colback=ming-gray!5, colframe=ming-gray!35,
    coltitle=ming-main, colbacktitle=ming-gray!12,
    fonttitle=\sffamily\bfseries\small,
    boxrule=0.4pt, arc=1pt, titlerule=0pt,
    left=6pt, right=6pt, top=3pt, bottom=3pt,
    before skip=8pt plus 2pt, after skip=8pt plus 2pt,
  },
}
\DeclareTCBListing{code}{ O{} O{} }{%
  ming/code, listing options={style=ming,#1}, #2}

% =============================================================================
% 10. 书籍结构环境
% =============================================================================
% 本章导读：\begin{introduction}[标题] \item ... \end{introduction}
\newtcolorbox{introduction}[1][\introductionname]{%
  ming/base,
  colback=ming-main!4, colframe=ming-main, coltitle=white, colbacktitle=ming-main,
  boxrule=0pt, toprule=0.6pt, bottomrule=0.6pt, arc=0pt, outer arc=0pt,
  attach boxed title to top left={xshift=0pt, yshift=-\tcboxedtitleheight/2},
  boxed title style={arc=0pt, outer arc=0pt, boxrule=0pt},
  top=10pt, left=6pt, right=6pt,
  title={#1},
  before upper={\begin{multicols}{2}\begin{itemize}},
  after upper={\end{itemize}\end{multicols}}}

% 本章小结
\newtcolorbox{summary}[1][\summaryname]{%
  ming/base,
  colback=ming-main!4, colframe=ming-main, coltitle=ming-main,
  boxrule=0pt, toprule=0.6pt, bottomrule=0.6pt, arc=0pt, outer arc=0pt,
  title={#1}, colbacktitle=ming-main!4, titlerule=0pt,
  left=6pt, right=6pt}

% 章末习题：自动进入目录和页眉，题号为“章.序号”
\newenvironment{problemset}[1][\problemsetname]
  {\section*{#1}%
   \addcontentsline{toc}{section}{#1}%
   \markright{#1}%
   \begin{enumerate}[label=\textcolor{ming-main}{\thechapter.\arabic*}, leftmargin=*, itemsep=4pt]}
  {\end{enumerate}}

% =============================================================================
% 11. 封面
% =============================================================================
\RequirePackage{tikz}
\usetikzlibrary{calc,arrows.meta}
\newcommand\subtitle[1]{\gdef\ming@subtitle{#1}}
\newcommand\institute[1]{\gdef\ming@institute{#1}}
\newcommand\version[1]{\gdef\ming@version{#1}}
\newcommand\extrainfo[1]{\gdef\ming@extrainfo{#1}}
\newcommand\coverimage[1]{\gdef\ming@coverimage{#1}}
\newcommand\logo[1]{\gdef\ming@logo{#1}}
\let\ming@subtitle\@empty
\let\ming@institute\@empty
\let\ming@version\@empty
\let\ming@extrainfo\@empty
\let\ming@coverimage\@empty
\let\ming@logo\@empty
\colorlet{ming-cover}{ming-main}

\newcommand\ming@infoline[2]{%
  \ifx#2\@empty\else
    {\color{ming-gray}#1}\enspace #2\\[2pt]%
  \fi}

\newcommand\ming@cover@band{%
  \begin{tikzpicture}[remember picture, overlay]
    % 上部：封面图或色块，占页高 46%
    \coordinate (band) at ($(current page.north west)!0.46!(current page.south west)$);
    \ifx\ming@coverimage\@empty
      \fill[ming-cover] (current page.north west) rectangle (band -| current page.east);
    \else
      \begin{scope}
        \clip (current page.north west) rectangle (band -| current page.east);
        \node[anchor=north, inner sep=0pt] at (current page.north)
          {\includegraphics[width=\paperwidth]{\ming@coverimage}};
      \end{scope}
    \fi
    \fill[ming-second] (band) rectangle ($(band -| current page.east)+(0,-3mm)$);
    % 标题区
    \node[anchor=north west, text width=0.78\paperwidth, align=left, inner sep=0pt]
      at ($(band)+(0.11\paperwidth,-22mm)$) {%
        {\sffamily\bfseries\fontsize{30}{38}\selectfont\color{ming-main}\@title\par}%
        \ifx\ming@subtitle\@empty\else
          \vspace{10pt}{\sffamily\Large\color{ming-gray}\ming@subtitle\par}\fi
        \vspace{26pt}%
        {\normalsize
          \ifx\@author\@empty\else{\color{ming-gray}\authorlabel}\enspace\@author\\[2pt]\fi
          \ming@infoline{\institutelabel}{\ming@institute}%
          \ifx\@date\@empty\else{\color{ming-gray}\datelabel}\enspace\@date\\[2pt]\fi
          \ming@infoline{\versionlabel}{\ming@version}}%
      };
    % 底部附加信息
    \ifx\ming@extrainfo\@empty\else
      \node[anchor=south west, text width=0.62\paperwidth, align=left, inner sep=0pt]
        at ($(current page.south west)+(0.11\paperwidth,22mm)$)
        {\small\color{ming-gray}\ming@extrainfo};
    \fi
    \ifx\ming@logo\@empty\else
      \node[anchor=south east, inner sep=0pt]
        at ($(current page.south east)+(-0.08\paperwidth,20mm)$)
        {\includegraphics[height=18mm]{\ming@logo}};
    \fi
  \end{tikzpicture}}

% 浅色封面：只用细线和浅灰线描，没有大面积色块，黑白打印也清楚省墨
\newcommand\ming@cover@print{%
  \begin{tikzpicture}[remember picture, overlay]
    \coordinate (L) at ($(current page.north west)+(0.11\paperwidth,0)$);
    \coordinate (R) at ($(current page.north east)+(-0.11\paperwidth,0)$);
    % 顶部双细线
    \draw[ming-main, line width=1.2pt] ($(L)+(0,-24mm)$) -- ($(R)+(0,-24mm)$);
    \draw[ming-main, line width=0.4pt] ($(L)+(0,-25.6mm)$) -- ($(R)+(0,-25.6mm)$);
    % 上部：封面图，或默认的函数线描
    \ifx\ming@coverimage\@empty
      \begin{scope}[shift={($(current page.north)+(0,-0.22\paperheight)$)},
                    x=0.055\paperwidth, y=0.055\paperwidth]
        \draw[black!10, line width=0.3pt, step=0.5] (-7,-2) grid (7,2);
        \draw[black!45, line width=0.5pt, -{Stealth[length=2.2mm]}] (-7.2,0) -- (7.3,0);
        \draw[black!45, line width=0.5pt, -{Stealth[length=2.2mm]}] (0,-2.2) -- (0,2.3);
        \draw[black!35, line width=0.5pt] (0,0) circle (1);
        \draw[black!35, line width=0.4pt] (0,0) -- (60:1) -- (0.5,0);
        \draw[black!30, line width=0.6pt, dashed, domain=-7:7, samples=160, smooth]
          plot (\x, {1.6*cos(\x r)});
        \draw[ming-main, line width=0.9pt, domain=-7:7, samples=160, smooth]
          plot (\x, {1.6*sin(\x r)});
        \fill[ming-second] (pi/2,1.6) circle (0.07);
      \end{scope}
    \else
      \node[inner sep=0pt] at ($(current page.north)+(0,-0.22\paperheight)$)
        {\includegraphics[width=0.78\paperwidth, height=0.26\paperheight, keepaspectratio]{\ming@coverimage}};
    \fi
    % 标题区
    \node[anchor=north west, text width=0.78\paperwidth, align=left, inner sep=0pt]
      at ($(L)+(0,-0.43\paperheight)$) {%
        {\sffamily\bfseries\fontsize{30}{38}\selectfont\color{ming-main}\@title\par}%
        \vspace{10pt}{\color{ming-second}\rule{28mm}{1.2pt}}\par
        \ifx\ming@subtitle\@empty\else
          \vspace{8pt}{\sffamily\Large\color{black!70}\ming@subtitle\par}\fi
        \vspace{26pt}%
        {\normalsize
          \ifx\@author\@empty\else{\color{ming-gray}\authorlabel}\enspace\@author\\[2pt]\fi
          \ming@infoline{\institutelabel}{\ming@institute}%
          \ifx\@date\@empty\else{\color{ming-gray}\datelabel}\enspace\@date\\[2pt]\fi
          \ming@infoline{\versionlabel}{\ming@version}}%
      };
    % 底部细线与附加信息
    \draw[ming-main, line width=0.4pt]
      ($(current page.south west)+(0.11\paperwidth,30mm)$) -- ($(current page.south east)+(-0.11\paperwidth,30mm)$);
    \ifx\ming@extrainfo\@empty\else
      \node[anchor=north west, text width=0.62\paperwidth, align=left, inner sep=0pt]
        at ($(current page.south west)+(0.11\paperwidth,26mm)$)
        {\small\color{ming-gray}\ming@extrainfo};
    \fi
    \ifx\ming@logo\@empty\else
      \node[anchor=north east, inner sep=0pt]
        at ($(current page.south east)+(-0.11\paperwidth,26mm)$)
        {\includegraphics[height=14mm]{\ming@logo}};
    \fi
  \end{tikzpicture}}

\renewcommand\maketitle{%
  \begingroup
  % 封面不建页面锚点，避免与正文第 1 页的锚点重名
  \hypersetup{pageanchor=false}%
  \begin{titlepage}
  \thispagestyle{empty}%
  \ming@ifprintcover{\ming@cover@print}{\ming@cover@band}%
  \end{titlepage}%
  \endgroup
  \setcounter{page}{1}}
\date{}

% =============================================================================
% 12. 参考文献
% =============================================================================
\RequirePackage[backend=biber, style=\ming@bibstyle]{biblatex}
\RequirePackage{csquotes}
\ming@ifcn{%
  \DefineBibliographyStrings{english}{bibliography={参考文献}, references={参考文献}}}{}
\endinput
