# LaTeX
Repository for LaTeX files I created for the most part using a TeX Live distroibution combined with Visual Studio Code LaTeX extensions.

# Installing Additional LaTeX packages
Add `RUN` commands to the _bottom_ of the Dockerfile to use the `tlmgr` [package manager](https://www.tug.org/texlive/pkginstall.html) for installing and updating Latex packages. For example: `RUN . ~/.bashrc && tlmgr install chktex`
