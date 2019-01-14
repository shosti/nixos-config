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
  alchemist
  calfw
  cider
  clojure-mode
  coffee-mode
  company-emoji
  company-ghc
  company-go
  company-terraform
  concurrent
  dash
  dash-functional
  diminish
  discover
  dockerfile-mode
  edit-server
  elisp-slime-nav
  elixir-mode
  emojify
  erlang
  ess
  evil
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
  ghc
  gist
  git-commit
  git-gutter
  git-gutter-fringe
  gitconfig-mode
  gitignore-mode
  go-eldoc
  go-mode
  go-scratch
  goto-last-change
  haml-mode
  haskell-mode
  helm
  highlight-parentheses
  htmlize
  idle-highlight-mode
  ido-completing-read-plus
  inf-ruby
  inflections
  js2-mode
  key-chord
  less-css-mode
  logito
  lua-mode
  macrostep
  magit
  markdown-mode
  mustache-mode
  nginx-mode
  paredit
  password-store
  prodigy
  ruby-compilation
  ruby-end
  ruby-tools
  rust-mode
  s
  scss-mode
  smex
  terraform-mode
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
  backup-each-save
  bash-completion
  bbdb
  crystal-mode
  ein
  emms
  evil-magit
  evil-paredit
  findr
  gh
  nix-mode
  projectile
  projectile-rails
  puppet-mode
  ox-reveal
  slack
  toml-mode
  wacspace
]) ++ (with epkgs.elpaPackages; [
  debbugs
  company
  company-statistics
  hydra
  nlinum
  rainbow-mode
  seq
  undo-tree
]) ++ (with epkgs.orgPackages; [
  org-plus-contrib
]) ++ ([
  beancount
]))
