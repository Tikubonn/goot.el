
;; require cl.el

(require 'cl)

;; provide goot

(provide 'goot)

;; define internal variables

(defvar goot-source nil "this is used dynamically in goot.el. so this is not used globally.")

(defvar goot-sources nil "this is used dynamically in goot.el. so this is not used globally.")

(defvar goot-used-return nil "this is used dynamically in goot.el. so this is not used globally.")

(defvar goot-break-symbol nil "this is used dynamically in goot.el. so this is not used globally.")

(defvar goot-continue-symbol nil "this is used dynamically in goot.el. so this is not used globally.")

(defvar goot-return-symbol nil "this is used dynamically in goot.el. so this is not used globally.")

(defvar goot-continue nil "this is used to hint for transforming in goot.el")

(defvar goot-break nil "this is used to hint for transforming in goot.el")

;; define alias macros

(defmacro goot-continue () "this is alias of symbol of `goot-continue'."
  'goot-continue)

(defmacro goot-break () "this is alias of symbol of  `goot-break'."
  'goot-break)

(defmacro goot-return (&optional value) "this transform to a formula."
  `(progn (setq goot-return ,value) (goot-break)))

;; goot-progn section
;; goot-progn for readable.

(defmacro goot-progn (&rest rest)
  (if (cdr rest)
    `(progn ,@rest)
    (car rest)))

;; goot-filter sectiom
;; return a filtered consing list,
;; because filter is not defined in the cl.el and standard methods.

(defun goot-filter (func sequence)
  (let ((result nil))
    (dolist (element sequence)
      (when (funcall func element)
        (push element result)))
    (nreverse result)))

;; goot-case section
;; this is not usefull for many cases.
;; this return a formula that is more smaller than elementary case macro.
;; so, more faster elementary case macro.

(defun goot-symfind (sym tree)
  (if (null tree) nil
    (if (consp tree)
      (or
        (goot-symfind sym (car tree))
        (goot-symfind sym (cdr tree)))
      (eq sym tree))))

;; goot-base-load section
;; translate to recipe for regeneration.
;; this use dynamic variables of goot-source and goot-sources.

(defun goot-base-load-confirm ()
  (push (nreverse goot-source) goot-sources)  
  (setq goot-source nil))

(defun goot-base-load (tree) 
  (if (null tree)
    (progn
      (push :nil goot-source))
    (if (consp tree)
      (progn
        (push :cons  goot-source)
        (goot-base-load (car tree))
        (goot-base-load (cdr tree)))
      (progn
        (push :pop goot-source)
        (case tree
          (goot-break (push  `(quote ,goot-break-symbol) goot-source) (goot-base-load-confirm))
          (goot-continue (push `(quote ,goot-continue-symbol) goot-source) (goot-base-load-confirm))
          (goot-return (push goot-return-symbol goot-source) (setq goot-used-return t))
          (otherwise (push tree goot-source)))))))

;; define goot-base-build section
;; regenerate a source tree from recipe.
;; this use a dynamic variable of goot-source.

(defun goot-base-build-internal ()
  (if (null goot-source) nil
    (case (pop goot-source)
      (:nil nil)
      (:pop (pop goot-source))
      (:cons
        (cons
          (goot-base-build-internal)
          (goot-base-build-internal))))))

(defun goot-base-build-trim ()
  (while (and goot-source (eq :nil (car goot-source)))
    (pop goot-source)))

(defun goot-base-build (source)
  (let ((goot-source source))
    (goot-base-build-trim)
    (goot-base-build-internal)))

;; new goot-base-build2 section
;; this is more faster than old version.
;; because it less generate nest progn.

(defun goot-base-build2 (sources &optional acc)
  (if (null sources) nil
    (if (equal `(quote ,goot-break-symbol) (car sources)) (macroexpand-all `(goot-progn ,@(nreverse acc) nil))
      (if (equal `(quote ,goot-continue-symbol) (car sources)) (progn (print acc) (macroexpand-all `(goot-progn ,@(nreverse acc) t))) ;; bug in here
        (if (goot-symfind goot-break-symbol (car sources))          
          (let*
            ((first (car sources))
              (second (goot-base-build2 (cdr sources)))
              (formula (if (eq second nil) `(progn ,first nil) `(if ,first nil ,second))))
            (if acc `(progn ,@(nreverse acc) ,formula) formula))
          (if (goot-symfind goot-continue-symbol (car sources))
            (let*
              ((first (car sources))
                (second (goot-base-build2 (cdr sources)))
                (formula (if (eq second t) `(progn ,first t) `(if ,first t ,second))))              
              (if acc `(progn  ,@(nreverse acc) ,formula) formula))
            (goot-base-build2 (cdr sources) (cons (car sources) acc))))))))

;; goot-base-buildmad section
;; this is most faster in the  goot.el
;; this has limit the position of goot-break/goot-continue.

(defun goot-base-build2mad-transform (tree)
  (if (null tree) nil    
    (if (consp tree)
      (if (equal `(quote ,goot-break-symbol) tree) t
        (if (equal `(quote ,goot-continue-symbol) tree) t
          (cons (goot-base-build2mad-transform (car tree))            
            (goot-base-build2mad-transform (cdr tree)))))
      (if (eq goot-break-symbol tree) nil
        (if (eq goot-continue-symbol tree) t
          tree)))))

(defun goot-base-build2mad (sources &optional acc)
  (if (null sources) nil
    (if (equal `(quote ,goot-break-symbol) (car sources)) (macroexpand-all `(goot-progn ,@(nreverse acc) nil))
      (if (equal `(quote ,goot-continue-symbol) (car sources)) (macroexpand-all`(goot-progn ,@(nreverse acc) t))
        (if (goot-symfind goot-break-symbol (car sources))
          (let*
            ((first (goot-base-build2mad-transform (car sources)))
              (second (goot-base-build2mad (cdr sources)))
              (formula (if (eq second nil) `(progn ,first nil) `(if ,first nil ,second))))
            (if acc `(progn ,@(nreverse acc) ,formula) formula))
          (if (goot-symfind goot-continue-symbol (car sources))
            (let*
              ((first (goot-base-build2mad-transform (car sources)))
                (second (goot-base-build2mad (cdr sources)))
                (formula (if (eq second t) `(progn ,first t) `(if ,first t ,second))))              
              (if acc `(progn ,@(nreverse acc) ,formula) formula))
            
            (goot-base-build2 (cdr sources) (cons (car sources) acc))))))))

;; goot-base section
;; translate the formula with goot-break/goot-continue symbols.
;; translated formula is not contain the exception oprators.

(defmacro goot-base  (condition &rest rest)

  "this transform to new source tree with use the `goot-break'/`goot-continue' symbols to hint the transform.
this transforming not use exception oprators, so this transformed is faster than using `catch'/`throw' functions."
  
  (let ((goot-source nil)
         (goot-sources nil)
         (goot-break-symbol (make-symbol "--goot-uninterned-break-symbol"))
         (goot-continue-symbol (make-symbol "--goot-uninterned-continue-symbol"))
         (goot-return-symbol (make-symbol "--goot-uninterned-return-symbol"))
         (goot-used-return nil))
    (setq rest
      (mapcar 'macroexpand-all rest))   
    (dolist (source rest)
      (goot-base-load source)
      (goot-base-load-confirm))
    (setq goot-sources
      (nreverse goot-sources))
    (setq goot-sources      
      (goot-filter (lambda (a) a)
        (mapcar 'goot-base-build goot-sources)))
    (let ((built (goot-base-build2 goot-sources)))
      (let ((built-cond (if (eq condition t) built `(and ,condition ,built))))
        (let ((built-while `(while ,built-cond)))
          (let ((built-return
                  (if goot-used-return
                    `(let ((,goot-return-symbol nil))
                       ,built-while
                       ,goot-return-symbol)
                    built-while)))
            built-return))))))

(defmacro goot-basemad (condition &rest rest)

  "this provide optimized `goot-base' that has some limitations.
so transformed formula is faster and lesser than `goot-base'.
you can see `goot-base' if you want to get more information."
  
  (let ((goot-source nil)
         (goot-sources nil)         
         (goot-break-symbol (make-symbol "--goot-uninterned-break-symbol"))
         (goot-continue-symbol (make-symbol "--goot-uninterned-continue-symbol"))
         (goot-return-symbol (make-symbol "--goot-uninterned-return-symbol"))
         (goot-used-return nil))
    (setq rest
      (mapcar 'macroexpand-all rest))    
    (dolist (source rest)
      (goot-base-load source)
      (goot-base-load-confirm))
    (setq goot-sources
      (nreverse goot-sources))    
    (setq goot-sources      
      (goot-filter (lambda (a) a)
        (mapcar 'goot-base-build goot-sources)))    
    (let ((built (goot-base-build2mad goot-sources)))
      (let ((built-cond (if (eq condition t) built `(and ,condition ,built))))
        (let ((built-while `(while ,built-cond)))
          (let ((built-return
                  (if goot-used-return
                    `(let ((,goot-return-symbol nil))
                       ,built-while
                       ,goot-return-symbol)
                    built-while)))
            built-return))))))

;; define provide methods

(defmacro goot-forever (&rest body)

  "this evaluate body section forever, until to reach the `goot-break'.
you can repeat this section from the beginning with using `goot-continue' oprator."

  `(goot-base t ,@body goot-continue))

(defmacro goot-while (condition &rest body)

  "this evaluate body section forever, until to reach the `goot-break', or condition was failed.
you can repeat this section from the beginning with using `goot-continue' oprator."

  `(goot-base ,condition ,@body goot-continue))

(defmacro goot-until (condition &rest body)

  "this evaluate body section forever, until to reach the `goot-break', or condition was successed.
you can repeat this section from the beginning with using `goot-continue' oprator."
  
  `(goot-base (not ,condition) ,@body goot-continue))

(defmacro goot-for (condition increment &rest body)

  "this evaluate body section forever, until to reach the `goot-break', or condition was failed.
you can repeat this section from the beginning with using `goot-continue'oprator.
increment is evaluate always at end of loop."
  
  `(goot-base ,condition (prog1 (progn ,@body goot-continue) ,increment)))

(defmacro goot-block (&rest body)

  "this evaluate body section one times.
you can repeat or abort this section with `goot-break' or `goot-continue' oprators."
  
  `(goot-base ,@body goot-break))

;; define provide optimized methods

(defmacro goot-forevermad (&rest body)

  "this provide a optimized `goot-forever' that has some limitations, so this is faster than `goot-forever'.
you can see `goot-forever' if you want to get more information."
  
  `(goot-basemad t ,@body goot-continue))

(defmacro goot-whilemad (condition &rest body)

  "this provide a optimized `goot-while' that has some limitations, so this is faster than `goot-while'.
you can see `goot-while' if you want to get more information."
  
  `(goot-basemad ,condition ,@body goot-continue))

(defmacro goot-untilmad (condition &rest body)

  "this provide a optimized `goot-until' that has some limitations, so this is faster than `goot-until'.
you can see `goot-until' if you want to get more information."
  
  `(goot-basemad (not ,condition) ,@body goot-continue))

(defmacro goot-formad (condition increment &rest body)

  "this provide a optimized `goot-for' that has some limitations, so this is faster than `goot-for'.
you can see `goot-for' if you want to get more information."
  
  `(goot-basemad ,condition (prog1 (progn ,@body goot-continue) ,increment)))

(defmacro goot-blockmad (&rest body)

  "this provide a optimized `goot-block' that has some limitations, so this is faster than `goot-block'.
you can see `goot-block' if you want to get more information."
  
  `(goot-basemad ,@body goot-break))

(defmacro goot-test (formula)
  (prog1 formula
    (print (macroexpand-all formula))))

(print
  (goot-test
    (let
      ((sum 0)
        (num 128))
      (goot-forever
        (if (= num 0) (goot-return sum))
        (incf sum num)
        (decf num)))))
