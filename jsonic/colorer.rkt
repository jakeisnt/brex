#lang br

(require brag/support syntax-color/racket-lexer racket/contract)


(define jsonic-lexer (lexer
  ;; at eof, need a special return value rather than lexer default, as we are syntax highlighting rather than parsing
  [(eof) (values lexeme 'eof #f #f #f)]
  [(:or "@$" "$@") (values lexeme 'parenthesis
                           ;; the parenthesis is escaped by vertical bars to properly use it as a token
                           ;; provide position of lexeme start or end dep on which
                           ;; assigned to the 'parenthesis coloring category
                           (if (equal? lexeme "@$") '|(| '|)|)
                               (pos lexeme-start) (pos lexeme-end))]
  [(:or "[" "]") (values lexeme 'parenthesis
                           ;; the parenthesis is escaped by vertical bars to properly use it as a token
                           ;; provide position of lexeme start or end dep on which
                           ;; assigned to the 'parenthesis coloring category
                           (if (equal? lexeme "[") '|(| '|)|)
                               (pos lexeme-start) (pos lexeme-end))]
  ;; any line prefixed with comment syntax must be a comment!
  [(from/to "//" "\n") (values lexeme 'comment #f (pos lexeme-start) (pos lexeme-end))]
  ;; anything else might just be a string?
  [any-char (values lexeme 'string #f (pos lexeme-start) (pos lexeme-end))]))
;;

(define (color-jsonic port offset racket-coloring-mode?)
  (cond
    ;; if not racket coloring mode or if ending the special racket syntax,
    ;; define values from information from the lexer and switch to racket mode
    ;; have to peek ahead to check for closing delimiter to determine whether to switch to the racket lexer,
    ;; as well as the existing state (are we already in racket mode? etc)
    [(or (not racket-coloring-mode?) (equal? (peek-string 2 0 port) "$@"))
     (define-values (str cat paren start end)
       (jsonic-lexer port))
     (define switch-to-racket-mode (equal? str "@$"))
     (values str cat paren start end 0 switch-to-racket-mode)]
   ;; here we are now in racket mode
    ;; just defer to what racket mode provides us
    [else
     (define-values (str cat paren start end) (racket-lexer port))
     (values str cat paren start end 0 #t)]))

(provide
 (contract-out
  [color-jsonic
   (input-port? exact-nonnegative-integer? boolean?
                . -> . (values
                        (or/c string? eof-object?) ;; can be either
                        symbol?
                        (or/c symbol? #f)
                        (or/c exact-positive-integer? #f)
                        (or/c exact-positive-integer? #f)
                        exact-nonnegative-integer?
                        boolean?))]))
;; can't test color-jsonic outright sometimes, because (values ...) returns lots of separate return values
;; i'm not sure what benefit this provides over returning a list of values (which can be better navigated!)
;; esp as i just end up converting back here. are they even represented differently internally?
(module+ test
  (require rackunit)
  (check-equal?
   (values->list (color-jsonic (open-input-string "x") 0 #f)) (list "x" 'string #f 1 2 0 #f)))