#| Test-Driven Development, and Recursion on Hierarchical Data |#

; Let's write a function to take a list and produce a list of all "leaf" elements, i.e. all non-list
;  elements from which it's built.

; For example [i.e, a test case]:
(check-expect (flatten (list (list "cat"
                                   "dog"
                                   "snail")
                             (list "rhino"
                                   "hippo")
                             (list)
                             (list "dolphin")))
              (list "cat"
                    "dog"
                    "snail"
                    "rhino"
                    "hippo"
                    "dolphin"))

#| The check-expect form takes two expressions and checks whether they produce the same value.

 If one or more check-expect test cases fail, a window appears with information about the failures.
 Because we follow test-driven development in CSC 104, we want to be able to write tests before
  defining the function, so check-expects may reference variables and functions defined later.
  The tests are implicitly moved to the end of the program. |#

; We also use check-expect to include checkable notes/documentation.
; Some examples of the csc104 function 'append':
(check-expect (append (list 3 2 4) (list 1 2 3))
              (list 3 2 4 1 2 3))
(check-expect (append (list 3 2 4) (list 1 2 3) (list 9 8 7))
              (list 3 2 4 1 2 3 9 8 7))
(check-expect (append (list 3 2 4))
              (list 3 2 4))
(check-expect (append (list))
              (list))
; Exercise. Predict and try:
#;(append (list (list 3 2 4) (list 1 2 3))) ; How many arguments are there? 1 do nothing
; (list (list 3 2 4) (list 1 2 3))

; Partial Design [create an expression intermediate between the argument and the result]:
(check-expect (flatten (list (list "cat"
                                   "dog"
                                   "snail")
                             (list "rhino"
                                   "hippo")
                             (list)
                             (list "dolphin")))
              ; *Manually* extract the four elements, give them to 'append':
              (append (list "cat"
                            "dog"
                            "snail")
                      (list "rhino"
                            "hippo")
                      (list)
                      (list "dolphin")))

; A full design, if the list is a list of lists of non-lists:
(check-expect (flatten (list (list "cat"
                                   "dog"
                                   "snail")
                             (list "rhino"
                                   "hippo")
                             (list)
                             (list "dolphin")))
              ; This expression uses the argument *as-is*, and uses *only* the knowledge that it is
              ;  a list of lists of non-lists. That is what makes it a full design [for those lists].
              (apply append
                     (list (list "cat"
                                 "dog"
                                 "snail")
                           (list "rhino"
                                 "hippo")
                           (list)
                           (list "dolphin"))))
; But we won't end up treating that case specially. So that check-expect was just practice.


; A test case having one more level of nesting:
(check-expect (flatten (list (list "bat"
                                   "rat")
                             (list (list "cat"        ; list of list of list here... 
                                         "dog"
                                         "snail")
                                   (list "dolphin"))))
              (list "bat"
                    "rat"
                    "cat"
                    "dog"
                    "snail"
                    "dolphin"))

; Partial Design:
(check-expect (flatten (list (list "bat"
                                   "rat")
                             (list (list "cat"
                                         "dog"
                                         "snail")
                                   (list "dolphin"))))
              (apply append
                     ; *Manually* inspected the list, found an element which itself is a nested list,
                     ;  and inserted a flatten call:
                     (list (list "bat"
                                 "rat")
                           (flatten (list (list "cat"
                                                "dog"
                                                "snail")
                                          (list "dolphin"))))))

; A natural thought is: take a look at each element of the original list, and flatten the ones
;  that need to be flattened. But we can save ourselves effort by not worrying about which ones
;  must be flattened, and make the computer work more instead: make it flatten each element.
(check-expect (flatten (list (list "bat"
                                   "rat")
                             (list (list "cat"
                                         "dog"
                                         "snail")
                                   (list "dolphin"))))
              (apply append
                     (list (flatten (list "bat"
                                          "rat"))
                           (flatten (list (list "cat"
                                                "dog"
                                                "snail")
                                          (list "dolphin"))))))

; That is a mapping:
(check-expect (flatten (list (list "bat"
                                   "rat")
                             (list (list "cat"
                                         "dog"
                                         "snail")
                                   (list "dolphin"))))
              (apply append
                     (map flatten (list (list "bat"
                                              "rat")
                                        (list (list "cat"
                                                    "dog"
                                                    "snail")
                                              (list "dolphin"))))))

; What if one of the list's elements is not a list?
; Again, there is a way to avoid treating it specially: we can decide to extend our definition
;  of flatten so that what it does to a non-list makes our current algorithm continue to work.

; Let's try that:
(check-expect (flatten (list (list "bat"
                                   "rat")
                             "mouse"
                             (list (list "cat"
                                         "dog")
                                   (list "dolphin"))))
              (apply append
                     (map flatten
                          ; Notice: argument appears exactly as-is.
                          (list (list "bat"
                                      "rat")
                                "mouse"
                                (list (list "cat"
                                            "dog")
                                      (list "dolphin"))))))

; For that to work we need:
(check-expect
 (apply append (list (flatten (list "bat"
                                    "rat"))
                     (flatten "mouse")
                     (flatten (list (list "cat"
                                          "dog")
                                    (list "dolphin")))))
 (apply append (list (list "bat"
                           "rat")
                     ; Flattening a non-list element needs to produce a list containing just it.
                     (list "mouse")
                     (list "cat"
                           "dog"
                           "dolphin"))))

; If we decide that flattening a non-list should produce a list containing that non-list,
;  then our algorithm continues to work without modification!

; Full Design for a non-list:
(check-expect (flatten "mouse") (list "mouse"))

; This is a common approach: extend a definition in a way that simplifies the main cases.

; So now our definition of flatten is just:

; flatten : any → list
(define (flatten anything)
  (cond [(list? anything) (apply append (map flatten anything))]
        [else (list anything)]))

; That small bit of code does a lot!

#| Practice the following calculations on paper, as if, for example, you were practicing calculating
    derivatives, row reducing matrices, etc: they require the same kind of practice to master.

 And you'll need the mastery of calculating strict by-value function calls, black-boxing recursions,
  mapping, applying, distinguishing collections from their elements, etc, when we build on them.
  That's no different than, for example, the need to reliably differentiate functions, to have a hope
  of integrating, curve sketching, finding maximums, etc. |#

(step parallel
      (flatten "cat")
      (flatten (list)))

(step parallel
      [hide (flatten "cat")
            (flatten "dog")]
      (flatten (list "cat"
                     "dog")))

(step parallel
      [hide (flatten (list "cat"
                           "dog"))
            (flatten (list "dolphin"))]
      (flatten (list (list "cat"
                           "dog")
                     (list "dolphin"))))

(step parallel
      [hide (flatten (list "bat"
                           "rat"))
            (flatten "mouse")
            (flatten (list (list "cat"
                                 "dog")
                           (list "dolphin")))]
      (flatten (list (list "bat"
                           "rat")
                     "mouse"
                     (list (list "cat"
                                 "dog")
                           (list "dolphin")))))
