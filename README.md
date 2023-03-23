# novelette
Simplified LuaLaTeX Document Class for Popular Fiction

Novelette is the younger, smaller sibling to the existing Novel document class.
It is faster, more accurate, and simpler to use. It achieves this by limiting
available setings and macros to only those that are absolutely necessary for
print-to-paper popular fiction. No frills, but my public library is full of
books that are well within the capability of Novelette.

This is a work in progress, as of late February 2023. The main features have
been tested, but are still subject to change. Thus, no documentation yet.
Power users can get a glimpse of what Novelette will do, by looking into
the code.

Expected release late March 2023.

UPDATE, March 23, 2023: Novelette works in its most essential features.
The frills also work, but are likely to be revised. Since TeXlive 2023
will soon be available, I will delay Novelette until my own system has
both 2022 and 2023 running.

If you would like to try Novelette (Linux, for now), do this: Copy directory
tex/lualatex/novelette to your home directory. Look inside for file
novelette-samplefile.tex. Build it to PDF with this command:
```
lualatex novelette-samplefile
```
If you are missing any packages in your TeX setup, then you will see the
usual problems. Novelette does not use a lot of packages, so you should
not need to install much.

The resulting PDF is in "align" mode. Margins are gray, and text baselines
are marked. You may edit the *tex file to see other modes.

Development continues. Documentation is very preliminary (what you see
inside doc directory is really just some basic info). Currently, I am tweaking
some of the alignment settings. The included Swainson fonts are not yet
ready for building to *.otf.

