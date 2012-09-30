(load "mk.scm")
(load "numbers.scm")

(define number-primo
  (lambda (exp env val)
    (fresh (n)
      (== `(intexp ,n) exp)
      (== `(intval ,n) val)
      (not-in-envo 'numo env))))

(define sub1-primo
  (lambda (exp env val)
    (fresh (e n n-1)
      (== `(sub1 ,e) exp)
      (== `(intval ,n-1) val)
      (not-in-envo 'sub1 env)
      (eval-expo e env `(intval ,n))
      (minuso n '(1) n-1))))

(define zero?-primo
  (lambda (exp env val)
    (fresh (e n)
      (== `(zero? ,e) exp)
      (conde
        ((zeroo n) (== #t val))
        ((poso n) (== #f val)))
      (not-in-envo 'zero? env)
      (eval-expo e env `(intval ,n)))))

(define *-primo
  (lambda (exp env val)
    (fresh (e1 e2 n1 n2 n3)
      (== `(* ,e1 ,e2) exp)
      (== `(intval ,n3) val)
      (not-in-envo '* env)
      (eval-expo e1 env `(intval ,n1))
      (eval-expo e2 env `(intval ,n2))
      (*o n1 n2 n3))))

(define if-primo
  (lambda (exp env val)
    (fresh (e1 e2 e3 t)
      (== `(if ,e1 ,e2 ,e3) exp)
      (not-in-envo 'if env)
      (eval-expo e1 env t)
      (conde
        ((== #t t) (eval-expo e2 env val))
        ((== #f t) (eval-expo e3 env val))))))

(define boolean-primo
  (lambda (exp env val)
    (conde
      ((== #t exp) (== #t val))
      ((== #f exp) (== #f val)))))

(define eval-expo
  (lambda (exp env val)
    (conde
      ((boolean-primo exp env val))
      ((number-primo exp env val))
      ((sub1-primo exp env val))
      ((zero?-primo exp env val))
      ((*-primo exp env val))
      ((if-primo exp env val))
      ((symbolo exp) (lookupo exp env val))
      ((fresh (rator rand x body env^ a)
         (== `(,rator ,rand) exp)
         (eval-expo rator env `(closure ,x ,body ,env^))
         (eval-expo rand env a)
         (eval-expo body `((,x . ,a) . ,env^) val)))
      ((fresh (x body)
         (== `(lambda (,x) ,body) exp)
         (symbolo x)
         (== `(closure ,x ,body ,env) val)
         (not-in-envo 'lambda env))))))

(define not-in-envo
  (lambda (x env)
    (conde
      ((fresh (y v rest)
         (== `((,y . ,v) . ,rest) env)
         (=/= y x)
         (not-in-envo x rest)))
      ((== '() env)))))

(define lookupo
  (lambda (x env t)
    (fresh (rest y v)
      (== `((,y . ,v) . ,rest) env)
      (conde
        ((== y x) (== v t))
        ((=/= y x) (lookupo x rest t))))))

(test-check "push-down problems 2"
  (run* (q) (fresh (x a d) (noo 'intval x) (== 'intval a) (== `(,a . ,d) x)))
  '())
  
(test-check "push-down problems 3"
  (run* (q) (fresh (x a d) (== `(,a . ,d) x) (noo 'intval x) (== 'intval a)))
  '())

(test-check "push-down problems 4"
  (run* (q) (fresh (x a d) (== `(,a . ,d) x) (== 'intval a) (noo 'intval x)))
  '())

(test-check "push-down problems 6"
  (run* (q) (fresh (x a d) (== 'intval a) (== `(,a . ,d) x) (noo 'intval x)))
  '())

(test-check "push-down problems 1"
  (run* (q) (fresh (x a d) (noo 'intval x) (== `(,a . ,d) x) (== 'intval a)))
  '())

(test-check "push-down problems 5"
  (run* (q) (fresh (x a d) (== 'intval a) (noo 'intval x) (== `(,a . ,d) x)))
  '())


(test-check "zero?"
  (run 1 (q) (eval-expo `(zero? (sub1 (intexp ,(build-num 1)))) '() q))
  '(#t))

(test-check "*"
  (run 1 (q) (eval-expo `(* (intexp ,(build-num 3)) (intexp ,(build-num 2))) '() `(intval ,(build-num 6))))
  '(_.0))

(test-check "sub1"
  (run 1 (q) (eval-expo q '() `(intval ,(build-num 6))) (== `(sub1 (intexp ,(build-num 7))) q))
  '((sub1 (intexp (1 1 1)))))

(test-check "sub1 bigger WAIT a minute"
  (run 1 (q)
    (eval-expo q '() `(intval ,(build-num 6)))
    (== `(sub1 (sub1 (intexp ,(build-num 8)))) q))
  '((sub1 (sub1 (intexp (0 0 0 1))))))

(test-check "sub1 biggest WAIT a minute"
  (run 1 (q)
    (eval-expo q '() `(intval ,(build-num 6)))
    (== `(sub1 (sub1 (sub1 (intexp ,(build-num 9))))) q))
  '((sub1 (sub1 (sub1 (intexp (1 0 0 1)))))))

(test-check "lots of programs to make a 6"
  (run 12 (q) (eval-expo q '() `(intval ,(build-num 6))))
  '((intexp (0 1 1)) (sub1 (intexp (1 1 1))) (* (intexp (1)) (intexp (0 1 1)))
  (* (intexp (0 1 1)) (intexp (1)))
  (if #t (intexp (0 1 1)) _.0)
  (* (intexp (0 1)) (intexp (1 1)))
  (if #f _.0 (intexp (0 1 1)))
  (sub1 (* (intexp (1)) (intexp (1 1 1))))
  (((lambda (_.0) (intexp (0 1 1))) #t)
    (=/= ((_.0 . numo)))
    (sym _.0))
  (sub1 (* (intexp (1 1 1)) (intexp (1))))
  (sub1 (sub1 (intexp (0 0 0 1))))
  (sub1 (if #t (intexp (1 1 1)) _.0))))

(define rel-fact5
  `((lambda (f)
      ((f f) (intexp ,(build-num 5))))
    (lambda (f)
      (lambda (n)
        (if (zero? n)
            (intexp ,(build-num 1))
            (* n ((f f) (sub1 n))))))))

(test-check "rel-fact5" 
  (run* (q) (eval-expo rel-fact5 '() q))
  `((intval ,(build-num 120))))

(test-check "rel-fact5-backwards" 
  (run 1 (q)
    (eval-expo
     `((lambda (f)
         ((f ,q) (intexp ,(build-num 5))))
       (lambda (f)
         (lambda (n)
           (if (zero? n)
               (intexp ,(build-num 1))
               (* n ((f f) (sub1 n)))))))
     '()
     `(intval ,(build-num 120))))
  `(f))
