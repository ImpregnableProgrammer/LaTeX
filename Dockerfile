# Create devcontainer with tex-live distribution
# Creates around ~700 MB LaTeX devcontainer image
FROM debian:stable-slim
# DEBIAN_FRONTEND: https://askubuntu.com/questions/972516/debian-frontend-environment-variable
ENV DEBIAN_FRONTEND=noninteractive
# Manually install texlive since the texlive package for Debian bookworm (stable) is out of date...
# This installs th4e latest TexLive distribution
# Install guide: https://www.tug.org/texlive/quickinstall.html
RUN apt-get update && apt-get install -y wget perl git && apt-get clean
RUN wget -O install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN zcat < install-tl-unx.tar.gz | tar -xf -
# install-tl documentation: https://www.tug.org/texlive/doc/install-tl.html
RUN cd install-tl-*/ && perl ./install-tl --no-interaction --paper=letter --scheme=scheme-basic --texdir=/usr/local/texlive/latest
# Update PATH variables as necessary
# Add /usr/local/texlive/latest/texmf-dist/doc/man to MANPATH (for `man`) - unneeded
# Add /usr/local/texlive/latest/texmf-dist/doc/info to INFOPATH (for `info`) - unneeded
# Add /usr/local/texlive/latest/bin/x86_64-linux/ to PATH
# Can also just create symlinks using `tlmgr`, but it's messier
# https://tex.stackexchange.com/questions/500300/after-a-completed-tex-live-installation-on-linux-how-can-i-run-just-the-create
RUN echo 'export PATH=/usr/local/texlive/latest/bin/x86_64-linux/:$PATH' >> ~/.bashrc
# tlmgr documentation: https://www.tug.org/texlive/doc/tlmgr.html
RUN . ~/.bashrc && tlmgr update --self --all
# Install dependencies for Mathematic LaTeX extension (for formatting and linting)
# latexindent ctan package: https://ctan.org/pkg/latexindent
# latexindent documentation: https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#manually-installing-modules
# Different perl package managers: https://stackoverflow.com/q/5861292/5661257
# cpanm(inus): https://metacpan.org/dist/App-cpanminus/view/bin/cpanm
RUN . ~/.bashrc && tlmgr install chktex latexindent
RUN apt-get install -y cpanminus && cpanm YAML::Tiny && cpanm File::HomeDir

## ADD ANY ADDITIONAL TEX PACKAGE INSTALLS BELOW THIS COMMENT!! ##
# Look up packages in CTAN: https://ctan.org
RUN . ~/.bashrc && tlmgr install latexmk mathtools fancybox booktabs tasks datetime etoolbox fmtcount xkeyval comfortaa blindtext fontawesome5