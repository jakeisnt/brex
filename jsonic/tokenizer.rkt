#lang br/quicklang
(require brag/support)

(define (make-tokenizer port)
  ;; must process every token, including eof, where we (prob) terminate
  (define (next-token)
    ;; contains series of branches, each representing lexing rule
    (define jsonic-lexer
      (lexer [;; ignore comments: everything from first to next argument (comment to newline)
 (from/to "//" "\n") (next-token)]
             [
              ;; everything between these two is valid Racket and should be used as such
 (from/to "@$" "$@") (token 'SEXP-TOK (trim-ends "@$" lexeme "$@"))]
             ;; any other token is JSON; we throw it away?
             ;; no real need to handle eof, as lexer emits eof token for parser eof
             [any-char (token 'CHAR-TOK lexeme)]))
    (jsonic-lexer port))
    next-token)

(provide make-tokenizer)