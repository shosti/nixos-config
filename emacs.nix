{ pkgs ? import <nixpkgs> {} }:

let myEmacs = pkgs.emacs.override {
  withGTK2 = false;
  withGTK3 = true;
  imagemagick = pkgs.imagemagick;
};

# Get the beancount elisp package, since it seems to not be available on MELPA
# for whatever reason...
beancount = pkgs.stdenv.mkDerivation rec {
  name = "beancount";
  version = "2.0.0";
  src = pkgs.fetchurl {
    url = "https://bitbucket.org/blais/${name}/get/${version}.tar.gz";
    sha256 = "0idj8his820mlmyfg955r4znw00ql97sdbhh887s5swdyb9wnady";
  };

  buildPhase = ''
    ${pkgs.emacs}/bin/emacs --batch -f batch-byte-compile editors/emacs/*.el
  '';

  installPhase = ''
    mkdir -p $out/share/emacs/site-lisp
    cp editors/emacs/*.el* $out/share/emacs/site-lisp/
  '';
};

emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;

in emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
  ace-jump-mode
  ag
  calfw
  cider
  clojure-mode
  coffee-mode
  company-emoji
  company-ghc
  company-go
  concurrent
  dash
  dash-functional
  diminish
  discover
  dockerfile-mode
  edit-server
  elisp-slime-nav
  elixir-mode
  emms
  emojify
  erlang
  evil
  evil-magit
  evil-matchit
  evil-nerd-commenter
  evil-surround
  expand-region
  f
  flx
  flx-ido
  flycheck
  flycheck-package
  fringe-helper
  gh
  ghc
  gist
  git-commit
  git-gutter
  git-gutter-fringe
  git-timemachine
  gitconfig-mode
  gitignore-mode
  go-eldoc
  go-mode
  go-scratch
  haml-mode
  haskell-mode
  helm
  highlight-parentheses
  idle-highlight-mode
  ido-completing-read-plus
  inf-ruby
  inflections
  js2-mode
  key-chord
  less-css-mode
  logito
  macrostep
  magit
  markdown-mode
  mmm-mode
  paredit
  password-store
  projectile
  projectile-rails
  ruby-end
  ruby-tools
  rust-mode
  s
  scss-mode
  smex
  vlf
  web-mode
  wgrep
  wgrep-ag
  which-key
  with-editor
  ws-butler
  yaml-mode
  yasnippet
]) ++ (with epkgs.melpaPackages; [
  evil-paredit
  nix-mode
  ox-reveal
  slack
  toml-mode
]) ++ (with epkgs.elpaPackages; [
  company
  company-statistics
  hydra
  nlinum
  seq
  undo-tree
]) ++ (with epkgs.orgPackages; [
  org-plus-contrib
]) ++ ([
  beancount
]))
