%% This is file `novelette.cls', lualatex `novelette' document class.
%% Copyright 2023 Robert Allgeyer.
%% Contact: Username `rallg' on GitHub and stackexchange. `RobtAll' on CTAN.
%%
%% This file may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either version 1.3c
%% of this license or (at your option) any later version.
%% The latest version of this license is in
%%    http://www.latex-project.org/lppl.txt
%% and version 1.3c or later is part of all distributions of LaTeX
%% version 2005/12/01 or later.
%% 
\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{novelette}%
[2023/01/20 v0.2 LuaLaTeX document class]
%%


%% DESCRIPTION:
%% ----------------------------------------------------------------------------
% Class `novelette' is a simplified version of the `novel' document class.
% It is designed for print fiction: novels or short stories. Most features
% needed for academic publications are disabled. It cannot produce an Ebook.
%   There are pre-configured designs for the most commonly used choices of
% trim size (finished book width and height), and internal design consistent
% with fiction. The user can over-ride the pre-configured settings.
%   The class will automatically create PDF/X-1a:2001 files upon request,
% using self-contained macros.
%   Program lualatex is required, and input files must be encoded utf-8.
% Command-line:  lualatex your-document.tex
% Some systems use this:  luahbtex --fmt=lualatex your-document.tex
%   Fonts are loaded by luaotfload and fontspec, and massaged by microtype.
% For best results, use modern Open Type fonts, or TrueType fonts.
%   The Libertinus Serif font family, if installed, is default.
% Last-choice default is Latin Modern Roman; using it generates a warning.
%   Images must be png monochrome, 1-bit per pixel, usually 600 pixels/inch.
%%


%% REQUIRE LUALATEX and do some preliminary setup.
%% ----------------------------------------------------------------------------
\RequirePackage{iftex} % Detects format.
\RequirePackage{luatex85} % Compatibility with old versions.
\RequirePackage{pdftexcmds} % Compatibility.
\ifluatex % Actually, lualatex.
  \pdfvariable suppressoptionalinfo 511 % Writes only ID to PDF Catalog.
\else
  \ClassError{novelette}{Must compile with lualatex}%
    {Either `lualatex' or `luahbtex --fmt=lualatex' at command line.}%
\fi
\nofiles % Does not need aux. Better without it.
\pdfimageresolution=600 % Default pixels/inch for monochrome bitmap images.
\pdfcompresslevel=0
\pdfobjcompresslevel=0
\pdfminorversion=3 % Required for optional PDF/X-1a:2001 conformance.
\gdef\thepdfminorversion{\pdfminorversion}
\def\nvt@revision{0}
%% Novelette uses these in a slightly different way than in other classes:
\protect\long\def\title#1{\gdef\nvt@title{#1}}
\title{Untitled Document}
\protect\long\def\author#1{\gdef\nvt@author{#1}}
\author{Anonymous Author}
\newcommand\application[1]{\gdef\nvt@application{#1}}
\application{Novelette}
\newcommand\producer[1]{\gdef\nvt@producer{#1}}
\producer{Novelette}
\@onlypreamble\title
\@onlypreamble\author
\@onlypreamble\application
\@onlypreamble\producer
%% \subtitle is for convenience. Not in PDF metadata.
\long\gdef\subtitle#1{\gdef\@subtitle{#1}\gdef\thesubtitle{#1}}
\@onlypreamble\subtitle
%%


%% BOOLEANS (Used here, and in other Novelette files.)
\newif\ifcolors@ % Always false. Compatibility.
\newif\ifmsdoc % Always false. Compatibility with some packages.
\newif\ifnvt@ok % Local scratch boolean. Typically used for and/or series.
\newif\ifnvt@sent@colormsg % When true, prevents color warning duplicates.
\newif\ifnvt@inopening % True within opening environment.
\newif\ifnvt@indisplay % True within display environment.
\newif\ifnvt@header % True if design style has header.
\newif\ifnvt@footer % True if design style has footer.
\newif\ifnvt@pnital % True if page numbers are italicized.
\newif\ifnvt@fnzmark % True if footnote is in opening. Omits the marker.
\newif\ifnvt@imgwarn % True if image warning issued.
\newif\ifnvt@frontmatter % True in frontmatter.
\newif\ifnvt@mainmatter % True in mainmatter or backmatter.
\newif\ifnvt@cleartoend % True if cleartoend issued. Prevents duplicate.
\newif\ifnvt@err % True if Novelette (not LaTeX) issued an error.
\newif\ifnvt@warnalert % True issues warning when alerts > 0.
\newif\ifnvt@warnalt % True if \altfont used without Libertinus Serif.
\newif\ifnvt@sheetfeed % True if \sheetfeed is other than trimsize.
%%


%% LENGTHS (Used in various Novelette files.)
\newlength\normalindent % Standard paragraph indent.
\newlength\nvt@totalh % Printable height, between top/bottom margins.
\newlength\nvt@fontsize % Main font size.
\newlength\nvt@leading % Standard baseline skip.
\newlength\nvt@dscn % Main font descender (depth of JQgjpqy).
\newlength\nvt@ascn % Main font ascender (height of accented Latin-1 capitals).
\newlength\nvt@Xht % X height of main font.
\newlength\nvt@xht % x height of main font.
\newlength\nvt@spad % Padding at sides of textblock, to allow for protrusion.
\newlength\nvt@trimw % Trim width.
\newlength\nvt@trimh % Trim height.
\newlength\nvt@mtop % Margin top.
\newlength\nvt@mout % Margin outside.
\newlength\nvt@mbot % Margin bottom.
\newlength\nvt@mins % Margin inside. At spine (binding).
\newlength\nvt@imgwidth % Image width (TeX pt).
\newlength\nvt@imgheight % Image height (TeX pt).
\newlength\nvt@intht % Integer multiple of \nvt@leading >= \nvt@imgheight.
\newlength\nvt@trimleft % Pagesize position of left edge of trimsize.
\newlength\nvt@spinew % Nominal width of spine glue area.
\newlength\nvt@temp@l % Local scratch length.
%%


%% COUNTERS (used in various Novelette files)
\newcounter{nvt@alert} \setcounter{nvt@alert}{0} % Number of alerts issued.
\newcounter{nvt@fnmnum} \setcounter{nvt@fnmnum}{1} % Footnote marker number.
\newcounter{nvt@mline} \setcounter{nvt@mline}{0} % Main text line number.
%%


%% REQUIRE SOME PACKAGES
%% ----------------------------------------------------------------------------
\RequirePackage{xparse} % For writing cool-looking commands.
\RequirePackage{letltxmacro} % For re-defining some macros.
\RequirePackage{etoolbox} % General good stuff.
\RequirePackage{xifthen} % Improved ifthenelse handling.
\RequirePackage{xstring} % Parses strings.
% Package fontspec requires normalsize. Trick: Tentative normalsize.
% Novelette calculates real normalsize AtEndPreamble.
\renewcommand\normalsize{\@setfontsize\normalsize{11pt}{14pt}}\normalsize
\RequirePackage[no-math,quiet]{fontspec}
\RequirePackage{luatexbase}
%%


%% CLASS OPTIONS (None!)
%% ----------------------------------------------------------------------------
% Novelette does not use class options to set dimensions, font size, or
% anything else. There may be a revision number (integer).
\edef\nvt@revreq{\nvt@revision}
\ifdefined\@raw@classoptionslist
  \IfInteger{\@raw@classoptionslist}{
    \xdef\nvt@revreq{\@raw@classoptionslist}
  }{
    \ifthenelse{\equal{\@raw@classoptionslist}{}}{}{
      \typeout{^^JALERT: Novelette has no class options. Ignored!^^J}
      \stepcounter{nvt@alert}
    }
  }
\fi
\def\@raw@classoptionslist{}
\def\@classoptionslist{}
%%


%% GENERAL DEFAULTS
%% ----------------------------------------------------------------------------
\defaultfontfeatures{} % Reset.
\defaultfontfeatures[\rmfamily,\sffamily]%
  {Kerning=On,Numbers=OldStyle,Ligatures=TeX,}
\def\nvt@mode{draft}
\def\nvt@intent{none}
\def\nvt@guides{}
\def\nvt@XN{Respond x to exit now. Fix the problem}
\def\nvt@RXN{Really, respond with x and exit now. Else bad things may happen.}
\def\nvt@bad{\global\nvt@errtrue\gdef\nvt@mode{draft}\gdef\nvt@intent{none}}
\def\nvt@error#1{\ClassError{novelette}{^^J#1^^J\nvt@XN}{\nvt@RXN}\nvt@bad}
\setlength\overfullrule{6pt} % Except in final mode.
%%


%% MORE PACKAGES
%% ----------------------------------------------------------------------------
\RequirePackage{novelette-language}
\RequirePackage[nomessages]{fp} % Calculations.
\FPmessagesfalse
\IfFileExists{silence.sty}{ % If not, no big deal.
  \RequirePackage{silence}
  \WarningFilter{microtype}{I cannot find a protrusion list}
  \WarningFilter{microtype}{protrusion}
  \WarningFilter{microtype}{Redefining}
  \WarningsOff[Fancyhdr,fancyhdr]
}{}
\RequirePackage{calc} % Length expression calculations.
\RequirePackage{atbegshi} % For header changes.
\RequirePackage{changepage} % Block indents, etc. Do not use strict!
\RequirePackage{noindentafter} % For unindented chapter and scene starts.
\RequirePackage{novelette-unglued}
\RequirePackage{novelette-utilities}
\RequirePackage{novelette-settings}
\RequirePackage{novelette-fonts}
\RequirePackage{novelette-design}
%%


%% PROHIBIT ADDING MORE PACKAGES
%% ----------------------------------------------------------------------------
% Many packages introduce code that disrupts the uniform line grid,
% or writes information disallowed by PDF/X. Solution: No user-added packages.
\LetLtxMacro\nvt@get@package\RequirePackage\relax
\NewDocumentCommand\out@of@luck{O{}m}{%
  \nvt@error{You cannot use \string\usepackage, or \string\RequirePackage.^^J%
    Novelette pre-loads only what is necessary. No frills allowed.}
}
\LetLtxMacro\RequirePackage\out@of@luck\relax
\LetLtxMacro\usepackage\out@of@luck\relax
%%


%% AT END PREAMBLE
%% ----------------------------------------------------------------------------
%% Process user settings, set defaults, calculate page design.
\AtEndPreamble{
  \LetLtxMacro\RequirePackage\nvt@get@package\relax
  \LetLtxMacro\usepackage\nvt@get@package\relax
  \ifthenelse{\equal{\nvt@mode}{final}}{}{\gdef\nvt@intent{none}}
  \nvt@process@trimsize
  \nvt@process@margins
  \nvt@process@design
  \RequirePackage{novelette-fonts}
  \nvt@process@mainfont
  \nvt@calculate@leading
  \nvt@renew@normalsize % The real value.
  \nvt@process@language
  \nvt@process@microset
  \RequirePackage[\nvt@microset]{microtype}
  \ifdefined\DeclareMicrotypeFilePrefix % From microtype version 3.1.
    \DeclareMicrotypeFilePrefix{nvt} % Load nvt-*.cfg for microtype.
  \else
    \def\MT@find@file#1{} % Prevents loading mt-*.cfg files AtBeginDocument.
  \fi
  \nvt@process@decofont
  \nvt@process@otherfonts
  \RequirePackage{novelette-footnotes}
  \gundef\opening
  \RequirePackage{novelette-opendisp}
  \RequirePackage{novelette-graphics}
  \RequirePackage{fancyhdr}
  \RequirePackage{novelette-headers}
  \nvt@processnvt@hfstyle
  \nvt@process@guides
  \RequirePackage{novelette-metadata}
  \nvt@process@metadata
  \nvt@process@pdfboxes
  \RequirePackage{novelette-shading}
  \ifthenelse{\equal{\nvt@mode}{final}}{\global\nvt@warnalertfalse}{}
  \ifthenelse{\equal{\nvt@mode}{draft}}{\nvt@labeldraft}{}
  \ifthenelse{\equal{\nvt@mode}{shade}}{\nvt@labelshade}{}
  \ifthenelse{\equal{\nvt@mode}{align}}{\nvt@labelalign}{}
  \RequirePackage{novelette-filler}
}
%%


%% AT BEGIN DOCUMENT (Finish the setup. Some values not available until here.)
%% ----------------------------------------------------------------------------
\AtBeginDocument{
  \global\deflength\textfloatsep{0pt plus \nvt@leading minus \nvt@leading}
  \global\deflength\parindent{\normalindent}
  \gdef\forceindent{\ifvmode\else\unskip\fi\stake\hspace{\normalindent}}
  \gdef\backindent{\ifvmode\else\unskip\fi\hspace{-\normalindent}}
  \DeclareDocumentCommand\textls{sO{}+m}{#3} % Do-nothing.
  \let\lsstyle\relax
  \hyphenpenalty=1000
  \exhyphenpenalty=1000
  \gdef\nvt@versohead{}
  \gdef\nvt@\rectohead{}
  \frenchspacing % Even if English.
}
%%


%% AFTER END PREAMBLE (Tacked onto the end of AtBeginDocument.)
%% ----------------------------------------------------------------------------
\AfterEndPreamble{ % Deactivate many special characters and macros.
  \catcode`\$=12
  \catcode`\_=12
  \catcode`\#=12
  \catcode`\&=12
  \catcode`\^=12
  \gdef\nvt@sdqused{ALERT: Used straightdblquote, page \thepage.}
  \begingroup
    \lccode`\~="0022
    \lowercase{\endgroup%
      \gdef~{\straightdblquote\typeout{\nvt@sdqused}\stepcounter{nvt@alert}}%
    }%
  \catcode`\"=13
  \def\({(}
  \def\){)}
  \def\[{[}
  \def\]{]}
  \gdef\nvt@pctused{ALERT: Used percent symbol for comment, page \thepage.}
  \begingroup
    \lccode`\~="0025
    \lowercase{\endgroup\gdef~{\typeout{\nvt@pctused}\stepcounter{nvt@alert}}%
    }%
  \catcode`\%=13
}
%%


%% AT END DOCUMENT (Document is still writeable here.)
%% ----------------------------------------------------------------------------
\AtEndDocument{
  \catcode`\%=14
  \catcode`\"=12
  \catcode`\$=3
  \catcode`\_=8
  \catcode`\#=6
  \catcode`\&=4
  \catcode`\^=7
  \cleartoend
  \iferrorsissued{\global\nvt@errtrue}{}
  \pdfinfo{%
    /CreationDate(\pdffeedback creationdate) %
    /ModDate(\pdffeedback creationdate) %
  }
  \nvt@attach@metadata
  \nvt@attach@xmp
  \ifthenelse{\equal{\nvt@intent}{none}}{}{\nvt@attach@intent}
  \ifnum\value{nvt@alert}=0\else
    \ifnvt@warnalert
      \ClassWarningNoLine{novelette}{One or more ALERT in log file}
    \fi
  \fi
}
%%


%% AFTER END DOCUMENT (Log final messages and summary.)
%% ----------------------------------------------------------------------------
\AfterEndDocument{
  \typeout{^^J}
  \typeout{*******************************************************************}
  \typeout{SUMMARY FOR JOBNAME \jobname}
  \typeout{*******************************************************************}
  \typeout{These are the actual values used. If different from your settings,}
  \typeout{it means Novelette used defaults, or needed to over-ride yours:}
  \typeout{\string\title{\@title}}
  \ifdefined\@subtitle\typeout{\string\subtitle{\@subtitle}}\fi
  \typeout{\string\author{\@author}}
  \typeout{\string\application{\nvt@application}}
  \typeout{\string\producer{\nvt@producer}}
  \typeout{\string\intent{\nvt@intent}}
  \typeout{\string\mode{\nvt@mode}}
  \typeout{\string\setlang{\nvt@setlang}}
  \typeout{\log@trimsize}
  \ifdefined\log@sheetfeed
    \typeout{\log@sheetfeed}
  \else
    \typeout{\string\sheetfeed{trimsize}}
  \fi
  \typeout{\log@margins}
  \typeout{\log@layout}
  \typeout{\log@text}
  \typeout{\space\space\log@charsperline}
  \FPclip{\nvt@temp@n}{\strip@pt\nvt@fontsize}
  \FPmul{\nvt@temp@d}{\nvt@temp@n}{.996264}
  \FPround{\nvt@temp@d}{\nvt@temp@d}{3}
  \FPclip{\nvt@temp@d}{\nvt@temp@d}
  \typeout{Size of main font: \nvt@temp@n pt TeX (\nvt@temp@d pt PostScript)}
  \FPround{\nvt@temp@n}{\strip@pt\nvt@leading}{2}
  \FPclip{\nvt@temp@n}{\nvt@temp@n}
  \FPmul{\nvt@temp@d}{\nvt@temp@n}{.996264}
  \FPround{\nvt@temp@d}{\nvt@temp@d}{2}
  \FPclip{\nvt@temp@d}{\nvt@temp@d}
  \typeout{Calculated leading (baselineskip): %
    \nvt@temp@n pt TeX (\nvt@temp@d pt PostScript)}
  \FPdiv{\nvt@temp@n}{\strip@pt\nvt@leading}{\strip@pt\nvt@fontsize}
  \FPround{\nvt@temp@n}{\nvt@temp@n}{2}
  \FPclip{\nvt@temp@n}{\nvt@temp@n}
  \typeout{Calculated ratio leading/fontsize: \nvt@temp@n}
  \typeout{\log@main}
  \typeout{\log@deco}
  \typeout{\log@mto}
  \log@imagespecs
  \typeout{\nvt@signoffmsg}
  \ifnum\value{nvt@alert}=0\else\typeout{ALERT(s) issued. See log file.}\fi
  \ifnvt@err\typeout{*** NOVELETTE ERROR. OUTPUT IS INVALID. ***}\fi
  \typeout{*******************************************************************}
  \typeout{^^J}
}
%%



%%
%% End of file `novelette.cls'.
%%
