#lang br
(require brag/support)

;; a digit is one or more of any character in the char set of all of the digits
(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define basic-lexer
  ;; variant of lexer that automatically gathers source location information
  (lexer-srcloc
   ;; starts newline: the start of a basic statement!
   ["\n" (token 'NEWLINE lexeme)]
   ;; optional argument to token that just skips the whitespace token in teh parser
   [whitespace (token lexeme #:skip? #t)]
   ;; stop before rem, tokenize rem to EOL as 'rem?
   [(from/stop-before "rem" "\n") (token 'REM lexeme)]
   ;; if it's one of our functions, we're cool just leaving the name as it is - we'll match it literally in parser anyways
   ;; nicer to have it as a token though - gives us source locations, can use consistent matching, etc.
   [(:or "print" "goto" "end" "+" ":" ";") (token lexeme lexeme)]
   ;; no decimal - just an integer
   [digits (token 'INTEGER (string->number lexeme))]
   ;; 0 or more digits before period, any after
   [(:or (:seq (:? digits) "." digits)
         ;; or digits ending with period. can't match a naked decimal point!
         (:seq digits "."))
    (token 'DECIMAL (string->number lexeme))]
   ;; match anything in single or double quotes
   [(:or (from/to "\"" "\"") (from/to "'" "'"))
    (token 'STRING
           ;; drop first and last chars of the matched lexeme - don't need the quote marks!
           (substring lexeme 1
                      (sub1 (string-length lexeme))))]))

(provide basic-lexer)
