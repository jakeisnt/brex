#lang br
(require jsonic/parser jsonic/tokenizer brag/support)


(parse-to-datum (apply-tokenizer-maker make-tokenizer "hi\n// comment\n@$ 42 $@"))

;; racket here string: multiline label with arbitrary name that will start and end the string
;; here, '#<<DEREK' declares the delimiter, then EOF is signalled where it is seen later
(parse-to-datum (apply-tokenizer-maker make-tokenizer #<<DEREK
"foo"
// comment
@$ 42 $@
DEREK
))