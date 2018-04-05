{ pkgs ? import <nixpkgs> {} }:

let
  myEmacs = pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = true;
    imagemagick = pkgs.imagemagick;
  };
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;
in emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
  emms
  magit
  ess
  calfw
  calfw-org
]) ++ (with epkgs.orgPackages; [
  org-plus-contrib
]))
