#lang br/quicklang

(require "parser.rkt")

; accept source path and input
(define (read-syntax path port)
  ; pass port to make-tokenizer, producing a function that reads characters and generates tokens
  ; these tokens are then passed to our parser
  (define parse-tree (parse path (make-tokenizer port)))
  ; create module-datum and insert the parse tree
  (define module-datum `(module bf-mod "expander.rkt" ,parse-tree))
  ; package code as syntax object
  (datum->syntax #f module-datum))


(require brag/support)
(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      (lexer
       ;; if the lexer gets something in this char set, make it a token!
       [(char-set "><-.,+[]") lexeme]
       ;; otherwise, go to the next token again
       [any-char (next-token)]))
    ;; call bf-lexer with the right port
    (bf-lexer port))
  next-token)

;; our parser now works the same way but it ignores silly tokens!


(provide read-syntax)
