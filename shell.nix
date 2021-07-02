{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell { buildInputs = [ racket rnix-lsp ]; }
