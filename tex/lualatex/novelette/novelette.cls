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
\ProvidesClass{novelette}[2023/01/20 v0.2 LuaLaTeX document class]
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
%   The EB Garamond font family, if installed, is default.
% The Libertinus Serif font family, if installed, is second default.
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
%% Novelette uses these in a slightly different way than in other classes:
\protect\long\gdef\title#1{\gdef\nvt@title{#1}}
\protect\long\gdef\author#1{\gdef\nvt@author{#1}}
\newcommand\application[1]{\gdef\nvt@application{#1}}
\newcommand\producer[1]{\gdef\nvt@producer{#1}}
\newcommand\intent[1]{\gdef\nvt@intent{#1}}
\@onlypreamble\title
\@onlypreamble\author
\@onlypreamble\application
\@onlypreamble\producer
\@onlypreamble\intent
%% \subtitle is for convenience. Not in PDF metadata.
\long\gdef\subtitle#1{\gdef\@subtitle{#1}\gdef\thesubtitle{#1}}
\@onlypreamble\subtitle
\subtitle{} % Default empty.
%%


%% BOOLEANS (Used here, and in other Novelette files.)
\newif\ifcolors@ % Always false. Compatibility.
\newif\ifmsdoc % Always false. Compatibility with some packages.
\newif\ifnvt@ok % Local scratch boolean. Typically used for and/or series.
\newif\ifnvt@sent@colormsg % When true, prevents color warning duplicates.
\newif\ifnvt@inopening % True within opening environment.
\newif\ifnvt@indisplay % True within display environment.
\newif\ifnvt@err % True if Novelette (not LaTeX) issued an error.
\newif\ifnvt@header % True if design style has header.
\newif\ifnvt@footer % True if design style has footer.
\newif\ifnvt@pnital % True if page numbers are italicized.
\newif\ifnvt@zmark % True if footnote is in opening. Omits the marker. 
\newif\ifnvt@frontmatter % True in frontmatter.
\newif\ifnvt@mainmatter % True in mainmatter or backmatter.
\newif\ifnvt@cleartoend % True if cleartoend issued. Prevents duplicate.
\newif\ifnvt@shadelines % True in align mode.
\newif\ifnvt@shademargins % True in shade mode.
\newif\ifnvt@draft % True unless final mode.
\newif\ifnvt@imgwarn % True if image warning issued.
\newif\ifnvt@imgdrop % True if image aligned to descender, instead of baseline.
\newif\ifnvt@error@thrown % True if any error detected during compile.
%%


%% LENGTHS (Used in various Novelette files.)
\newlength\normalindent % Standard paragraph indent.
\newlength\nvt@totalh % Printable height, between top/bottom margins.
\newlength\nvt@fontsize % Main font size.
\newlength\nvt@leading % Standard baseline skip.
\newlength\nvt@dscn % Main font descender (depth of JQgjpqy).
\newlength\nvt@ascn % Main font ascender (height of accented Latin-1 capitals).
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


%% REQUIRE SOME PACKAGES
%% ----------------------------------------------------------------------------
\RequirePackage{xparse} % For writing cool-looking commands.
\RequirePackage{letltxmacro} % For re-defining some macros.
\RequirePackage{etoolbox} % general good stuff
\RequirePackage{xifthen} % improved ifthenelse handling
\RequirePackage{xstring} % parses strings
\RequirePackage{novelette-infwarerr}
% Package fontspec requires normalsize. Trick: Tentative normalsize.
% Novelette calculates real normalsize AtEndPreamble.
\renewcommand\normalsize{\@setfontsize\normalsize{11pt}{14pt}}\normalsize
\RequirePackage[no-math,quiet]{fontspec}
%%


%% CLASS OPTIONS (none!), MODE
%% ----------------------------------------------------------------------------
% Novelette does not use class options. Dimensions, font size, and everything
% are are set by specific commands in Preamble.
%   \mode{choose} selects draft, shade, align, final. Default draft.
\ifdefined\@raw@classoptionslist
  \ifthenelse{\equal{\@raw@classoptionslist}{}}{}{
    \typeout{^^JALERT: Novelette has no class options. Ignored!^^J}
  }
\fi
\def\@raw@classoptionslist{}
\def\@classoptionslist{}
\newcommand\mode[1]{
  \nvt@okfalse
  \StrDel{#1}{ }[\nvt@temp@s]
  \ifdefined\nvt@mode % Prevent duplicates.
    \def\nvt@temp@s{draft}
    \ClassWarning{novelette}{Multiple usage of \string\mode^^J%
      All ignored. Using draft mode instead.}
  \fi
  \ifthenelse{\equal{\nvt@temp@s}{draft}}{
    \nvt@oktrue\nvt@drafttrue\gdef\nvt@mode{draft}
    \nvt@shademarginsfalse\nvt@shadelinesfalse
  }{}
  \ifthenelse{\equal{\nvt@temp@s}{shade}}{
    \nvt@oktrue\nvt@drafttrue\gdef\nvt@mode{shade}
    \nvt@shademarginstrue\nvt@shadelinesfalse
  }{}
  \ifthenelse{\equal{\nvt@temp@s}{align}}{
    \nvt@oktrue\nvt@drafttrue\gdef\nvt@mode{align}
    \nvt@shademarginstrue\nvt@shadelinestrue
  }{}
  \ifthenelse{\equal{\nvt@temp@s}{final}}{
    \nvt@oktrue\nvt@draftfalse\gdef\nvt@mode{final}
    \nvt@shademarginsfalse\nvt@shadelinesfalse
  }{}
  \ifnvt@ok\else
    \gdef\nvt@mode{draft}
    \ClassWarning{novelette}{Unknown \string\mode{\nvt@temp@s}.^^J%
      Ignored. Using draft mode instead.}
  \fi
}
\@onlypreamble\mode
%%


%% MORE PACKAGES
%% ----------------------------------------------------------------------------
\RequirePackage{novelette-language}
\RequirePackage[nomessages]{fp} % Calculations.
\FPmessagesfalse
\RequirePackage{silence}
\WarningFilter{microtype}{I cannot find a protrusion list}
\WarningFilter{microtype}{protrusion}
\WarningFilter{microtype}{Redefining}
\WarningsOff[Fancyhdr,fancyhdr]
\RequirePackage{calc} % Length expression calculations.
\RequirePackage{atbegshi} % For header changes.
\RequirePackage{changepage} % Block indents, etc. Do not use strict!
\RequirePackage{noindentafter} % For unindented chapter and scene starts.
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
\NewDocumentCommand\out@of@luck{O{}m}{\nvt@errCURP} % Cannot use \RequirePackage.
\LetLtxMacro\RequirePackage\out@of@luck\relax
\LetLtxMacro\usepackage\out@of@luck\relax
%%


%% AT END PREAMBLE
%% ----------------------------------------------------------------------------
%% Process user settings, set defaults, calculate page design.
\AtEndPreamble{
  \ifdefined\nvt@mode\else\gdef\nvt@mode{draft}\fi
  \ifthenelse{\equal{\nvt@mode}{final}}{
    \global\deflength\overfullrule{0pt}
  }{
    \global\deflength\overfullrule{6pt}
  }
  \LetLtxMacro\RequirePackage\nvt@get@package\relax
  \LetLtxMacro\usepackage\nvt@get@package\relax
  \ifundef{\nvt@title}{
    \global\nvt@drafttrue
    \gdef\@title{Untitled Document}
    \gdef\thetitle{Untitled Document}
  }{
    \xdef\@title{\nvt@title}
    \xdef\thetitle{\nvt@title}
  }
  \ifundef{\nvt@author}{
    \global\nvt@drafttrue
    \gdef\@author{Anonymous Author}
    \gdef\theauthor{Anonymous Author}
  }{
    \xdef\@author{\nvt@author}
    \xdef\theauthor{\nvt@author}
  }
  \ifundef{\nvt@application}{\gdef\nvt@application{Novelette}}{}
  \ifundef{\nvt@producer}{\gdef\nvt@producer{Novelette}}{}
  \ifundef{\nvt@intent}{\gdef\nvt@intent{none}}{}
  \nvt@process@margins
  \nvt@process@design
  \RequirePackage{novelette-fonts}
  \nvt@process@mainfont
  \nvt@calculate@leading
  \nvt@renew@normalsize % The real value.
  \DeclareDocumentCommand\lipsum{sO{}o}{\nvt@errLINL} % Lipsum is not loaded.
  \nvt@process@language
  \nvt@process@MT
  \gundef\setmicrotype
  \RequirePackage[\nvt@MT]{microtype}
  \def\MT@find@file#1{} % Prevents loading mt-*.cfg files AtBeginDocument.
  \nvt@process@headfont
  \nvt@process@otherfonts
  \RequirePackage{novelette-footnotes}
  \RequirePackage{novelette-opendisp}
  \RequirePackage{novelette-graphics}
  \RequirePackage{fancyhdr}
  \RequirePackage{novelette-headers}
  \nvt@processnvt@hfstyle
  \nvt@process@openings
  \RequirePackage{novelette-fillertext}
  \RequirePackage{novelette-shading}
  \ifthenelse{\equal{\nvt@mode}{draft}}{\nvt@labeldraft}{}
  \ifthenelse{\equal{\nvt@mode}{shade}}{\nvt@labelshade}{}
  \ifthenelse{\equal{\nvt@mode}{align}}{\nvt@labelalign}{}
  \RequirePackage{novelette-metadata}
  \nvt@process@pdfboxes
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
}
%%


%% AFTER END PREAMBLE (Tacked onto the end of AtBeginDocument.)
%% ----------------------------------------------------------------------------
\AfterEndPreamble{
  \versohead{Verso}\rectohead{Recto} % Dummy fill.
}
%%


%% AT END DOCUMENT (Document is still writeable here.)
%% ----------------------------------------------------------------------------
\AtEndDocument{
  \cleartoend
  \pdfinfo{%
    /CreationDate(\pdffeedback creationdate) %
    /ModDate(\pdffeedback creationdate) %
  }
  \nvt@process@metadata
  \nvt@process@xmp
  \ifthenelse{\equal{\nvt@intent}{none}}{}{\nvt@processnvt@intent}
}
%%


%% AFTER END DOCUMENT (Log final messages and summary.)
%% ----------------------------------------------------------------------------
\AfterEndDocument{
  \typeout{^^J}
  \typeout{*******************************************************************}
  \typeout{SUMMARY FOR JOBNAME \jobname\space\ifnvt@draft DRAFT MODE\fi}
  \typeout{*******************************************************************}
  \typeout{These are the actual values used. If different from your settings,}
  \typeout{it means Novelette used defaults, or needed to over-ride yours:}
  \typeout{\string\title{\@title}}
  \typeout{\string\subtitle{\@subtitle}}
  \typeout{\string\author{\@author}}
  \typeout{\string\application{\nvt@application}}
  \typeout{\string\producer{\nvt@producer}}
  \typeout{\string\intent{\nvt@intent}}
  \typeout{\string\mode{\nvt@mode}}
  \typeout{\string\setlang{\nvt@lang}}
  \typeout{\log@trimsize}
  \typeout{\log@sheetfeed}
  \typeout{\log@margins}
  \typeout{\log@design}
  \typeout{\log@openings}
  \typeout{\lognvt@markers}
  \FPclip{\nvt@temp@n}{\strip@pt\nvt@fontsize}
  \FPmul{\nvt@temp@d}{\nvt@temp@n}{.996264}
  \FPround{\nvt@temp@d}{\nvt@temp@d}{3}
  \FPclip{\nvt@temp@d}{\nvt@temp@d}
  \typeout{Size of main font: \nvt@temp@n pt TeX (\nvt@temp@d pt PostScript)}
  \FPmul{\nvt@temp@n}{\nvt@temp@n}{.45}
  \FPdiv{\nvt@temp@n}{\strip@pt\textwidth}{\nvt@temp@n}
  \FPtrunc{\nvt@temp@n}{\nvt@temp@n}{0}
  \typeout{Estimated average \nvt@temp@n\space characters/line (incl. spaces)}
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
  \typeout{\log@mainfont}
  \typeout{\log@headfont}
  \typeout{\log@namefont}
  \typeout{\log@descfont}
  \typeout{\log@notefont}
  \typeout{\log@decofont}
  \log@imagespecs
  \typeout{\nvt@signoffmsg}
  \ifnvt@err
    \typeout{*** NOVELETTE ERROR. OUTPUT IS INVALID. ***}
    \typeout{*** PDF CANNOT MEET PDF/X REQUIREMENTS. ***}
  \fi
  \typeout{*******************************************************************}
  \typeout{^^J}
}
%%


%  \catcode`\$=12
%  \catcode`\&=12
%  \def\({(} % No math mode.
%  \def\){)}




%%
%% End of file `novelette.cls'.
