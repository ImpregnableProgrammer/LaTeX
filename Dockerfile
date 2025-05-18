# Create devcontainer with tex-live distribution
# Creates around ~700 MB LaTeX devcontainer image
# FROM --platform=linux/amd64 debian:stable-slim
FROM debian:stable-slim
# DEBIAN_FRONTEND: https://askubuntu.com/questions/972516/debian-frontend-environment-variable
ENV DEBIAN_FRONTEND=noninteractive
# Manually install texlive since the texlive package for Debian bookworm (stable) is out of date...
# This installs th4e latest TexLive distribution
# Install guide: https://www.tug.org/texlive/quickinstall.html
# Install java on Ubuntu/Debian-based systems: https://ubuntu.com/tutorials/install-jre
# Java needed for `ltex` extension: https://valentjn.github.io/ltex/index.html
# `apt` vs `apt-get`: https://aws.amazon.com/compare/the-difference-between-apt-and-apt-get/
# `apt-get` is more stable in scripts, but has no search functionality
RUN apt-get update && apt-get install -y curl default-jre git gpg perl wget && apt-get clean
ADD https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz install-tl-unx.tar.gz
RUN zcat < install-tl-unx.tar.gz | tar -xf -
# install-tl documentation: https://www.tug.org/texlive/doc/install-tl.html
# Use `cd` since we only want to change directory for this RUN instruction and revert thereafter
RUN cd install-tl-*/ && \
  perl ./install-tl --no-interaction --paper=letter \
  --scheme=scheme-basic --texdir=/usr/local/texlive/latest
# Update PATH variables as necessary
# Add /usr/local/texlive/latest/texmf-dist/doc/man to MANPATH (for `man`) - unneeded
# Add /usr/local/texlive/latest/texmf-dist/doc/info to INFOPATH (for `info`) - unneeded
# Add /usr/local/texlive/latest/bin/x86_64-linux/ to PATH
# Can also just create symlinks using `tlmgr`, but it's messier
# https://tex.stackexchange.com/questions/500300/after-a-completed-tex-live-installation-on-linux-how-can-i-run-just-the-create
RUN echo 'for d in /usr/local/texlive/latest/bin/*; do export PATH=${d}:${PATH}; done' >> ~/.bashrc
# tlmgr documentation: https://www.tug.org/texlive/doc/tlmgr.html
RUN . ~/.bashrc && tlmgr update --self --all
# Install dependencies for Mathematic LaTeX extension (for formatting and linting)
# latexindent ctan package: https://ctan.org/pkg/latexindent
# latexindent documentation: https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#manually-installing-modules
# Different perl package managers: https://stackoverflow.com/q/5861292/5661257
# cpanm(inus): https://metacpan.org/dist/App-cpanminus/view/bin/cpanm
RUN . ~/.bashrc && tlmgr install chktex latexindent
RUN apt-get install -y cpanminus && apt-get clean && cpanm YAML::Tiny && cpanm File::HomeDir

## ADD ANY ADDITIONAL TEX PACKAGE INSTALLS BELOW THIS COMMENT!! ##
# Look up packages in CTAN: https://ctan.org
RUN . ~/.bashrc && \
  tlmgr install latexmk mathtools fancybox \
  booktabs tasks datetime \
  etoolbox fmtcount xkeyval \
  comfortaa blindtext fontawesome5 \
  wrapfig fundus-calligra calligra \
  ragged2e texcount ieeetran times xcolor listings multirow cite algorithmicx caption
# Properly set system locale settings
ENV LANGUAGE=C.UTF8
ENV LC_ALL=C.UTF8
ENV LANG=en_US.UTF-8
# Install starship fancy command line and configure it
# https://github.com/starship/starship
RUN curl -sS https://starship.rs/install.sh >> starship_install.sh
RUN chmod +x starship_install.sh && ./starship_install.sh -y
RUN echo 'eval "$(starship init bash)"' >> ~/.bashrc
# Configure git for commit signing with GPG if GPG_SIGNING_KEY env var is defined
# To use: add `export GPG_SIGNING_KEY=<GPG KEY ID>` to your `~/.bash_profile`
ARG GPG_SIGNING_KEY
RUN if [[ -n ${GPG_SIGNING_KEY} ]]; then \
  git config --global user.signingkey ${GPG_SIGNING_KEY}; \
  git config --global commit.gpgSign true; \
  git config --global tag.gpgSign true; \
  fi