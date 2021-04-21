#lang brag

jsonic-program : (jsonic-char | jsonic-sexp)*
;; when the parser matches a named token,
;; it pulls the matched string out of the token and into the parse tree
;; as such we will no longer have refs to TOK there.
jsonic-char : CHAR-TOK
jsonic-sexp : SEXP-TOK