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

# For some reason this isn't in the autogenerated list (maybe too new?)
backup-each-save = (pkgs.emacsPackagesNgGen myEmacs).melpaBuild rec {
  pname = "backup-each-save";
  version = "20180226.2157";

  src = pkgs.fetchFromGitHub {
    owner = "conornash";
    repo = "backup-each-save";
    rev = "3c414b9d6b278911c95c5b8b71819e6af6f8a02a";
    sha256 = "13pliz2ra020hhxcidkyhfa0767n188l1w5r0vpvv6zqyc2p414i";
  };

  recipeFile = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/melpa/melpa/475bd8fd66c6d5b5c7e74aa2c4e094d313cc8303/recipes/backup-each-save";
    sha256 = "1l7lx3vd27qypkxa0cdm8zbd9fv08xn1bf6xj6g9c49ql95xbyiv";
    name = "backup-each-save";
  };
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
  gh
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
  projectile
  projectile-rails
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
  bash-completion
  bbdb
  crystal-mode
  emms
  evil-magit
  evil-paredit
  findr
  nix-mode
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
  backup-each-save
  beancount
]))
