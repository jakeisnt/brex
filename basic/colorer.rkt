#lang br
(require "lexer.rkt" brag/support)

;; this chapter switches conventions - providing at beginning of file rather than eof.
(provide basic-colorer)

(define (basic-colorer port)
  (define (handle-lexer-error excn)
    ;; store the exceptions in the exception object; retrieve the first
    (define excn-srclocs (exn:fail:read-srclocs excn))
    (srcloc-token (token 'ERROR) (car excn-srclocs)))
  ;; can't just use the basic lexer for this - it can error! we need to catch those errors and not break the editor.
  (define srcloc-tok
    (with-handlers ([exn:fail:read-srclocs excn]) (basic-lexer port)))
  (match srcloc-tok
    ;; question mark uses predicate as a match pattern without binding the variable matched
    [(? eof-object?) (values srcloc-tok 'eof #f #f #f)]
    [else
      (match-define
        (srcloc-token
          (token-struct type val _ _ _ _ _)
          (srcloc _ _ _ posn span)) srcloc-tok)
      (define start posn)
      (define end (+ start span))
      (match-define (list cat paren)
        (match type
          ['STRING '(string #f)]
          ['REM '(comment #f)]
          ['ERROR '(error #f)]
          [else (match val
                  ;; not specific values, so have to match with recognizers instead
                  [(? number?) '(constant #f)]
                  [(? symbol?) '(symbol #f)]
                  ;; just parens, no types involved here
                  ["(" '(parenthesis |(|))]
                  [")" '(parenthesis |(|))]
                  [else '(no-color #f)])]))
      (values val cat paren start end)]))

;; in practice, can't differentiateline numbers from other 'INTEGER tokens with our simplified syntax tree
;; would need a separate lexer, or a more complex one for which more rules are implemented throughout the codebase
