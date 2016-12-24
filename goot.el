
;; require cl.el

(require 'cl)

;; provide goot.el 

(provide 'goot)

;; define internal variables 

(defvar goot-recipe nil)

(defvar goot-recipes nil)

(defconst goot-continue-symbol
  (let ((symcontinue (gensym)))
    (prog1 symcontinue
      (setf (symbol-value symcontinue) symcontinue))))

(defconst goot-break-symbol
  (let ((symbreak (gensym)))
    (prog1 symbreak
      (setf (symbol-value symbreak) symbreak))))

;; define internal methods

(defmacro goot-pop-recipe ()
  `(pop goot-recipe))

(defmacro goot-push-recipe (element)
  `(push ,element goot-recipe))

(defmacro goot-push-recipes ()
  `(progn 
     (push (nreverse goot-recipe) goot-recipes)
     (setq goot-recipe nil)))

(defmacro goot-ignore-close ()
  `(while (and goot-recipe (eq :close (car goot-recipe)))
     (pop goot-recipe)))

(defmacro goot-filter (func sequence)
  (let
    ((symsequence (gensym))
      (symelement (gensym)))
    `(let ((,symsequence nil))
       (dolist (,symelement ,sequence)
         (when(funcall ,func ,symelement)
           (push ,symelement ,symsequence)))
       (nreverse ,symsequence))))

(defmacro goot-case4 (formula &rest conditions)
  (goot-case-internal4 formula conditions))

(defun goot-case-internal4 (formula conditions &optional expanded)
  (when conditions
    (if (eq 'otherwise (caar conditions))
      (if (null expanded)
        `(goot-progn ,formula ,(car (cdar conditions)))
        `(goot-progn ,@(cdar conditions)))
      (if (goot-symfind (caar conditions) formula)
        `(if (eq ,formula ,(caar conditions))
           (goot-progn ,@(cdar conditions))
           ,(goot-case-internal4 formula (cdr conditions) t))
        (goot-case-internal4 formula (cdr conditions) expanded)))))

(defmacro goot-progn (&rest rest)
  (if (cdr rest) `(progn ,@rest) (car rest)))

(defun goot-symfind (sym formula)
  (if (null formula) nil
    (if (consp formula)
      (or
        (goot-symfind sym (car formula))
        (goot-symfind sym (cdr formula)))
      (eq sym formula))))

(defmacro goot-test (formula)
  (prog1 formula
    (print (macroexpand-all formula))))

(defmacro goot-listen (&rest formula)

    ;; allocate temp variables to local scope 
  
  (let
    ((goot-recipe nil)
      (goot-recipes nil))

    ;; read source tree and
    ;; stack the elements to source tree recipes 

    (dolist (form formula)
      (goot-listen-internal form)
      (when goot-recipe (goot-push-recipes)))
    
    (setq goot-recipes
      (nreverse goot-recipes))

    ;; generate a list of source tree
    ;; with a source tree recipe
    
    (setq goot-recipes
      
      (mapcar
        (lambda (goot-recipe)
          (goot-build))
        
        (goot-filter
          (lambda (a) a)
          
          (mapcar
            (lambda (goot-recipe)
              (goot-ignore-close)
              goot-recipe)
            
            goot-recipes))))

    ;; build ( translate ) to nested
    ;; source tree

    (goot-build2 goot-recipes)))

(defun goot-build2 (formula)
  (when formula
    (case (car formula)      
      (:goot-break nil)
      (:goot-continue t)      
      (otherwise
        `(goot-case4 ,(car formula)
           (:goot-break nil)
           (:goot-continue t)
           (otherwise ,(goot-build2 (cdr formula))))))))

(defun goot-build ()
  (when goot-recipe
    (let ((element (goot-pop-recipe)))
      (case element
        (:open          
          (let*
            ((element-car (goot-build))
              (element-cdr (goot-build)))
            (cons element-car element-cdr)))        
        (:close nil)
        (otherwise element)))))

(defun goot-listen-internal (formula) 
  (if (null formula)
    (goot-push-recipe :close)    
    (if (consp formula)
      (progn        
        (goot-push-recipe :open)
        (goot-listen-internal (car formula))
        (goot-listen-internal (cdr formula)))      
      (progn
        (case formula
          (goot-break (goot-push-recipe :goot-break) (goot-push-recipes))
          (goot-continue (goot-push-recipe :goot-continue) (goot-push-recipes))
          (otherwise (goot-push-recipe formula))))
      )))

;; define basic methods

(defmacro goot-while (condition &rest rest)
  `(while (and ,condition (goot-listen ,@rest goot-continue))))

(defmacro goot-until (condition &rest rest)
  `(while (and (not ,condition) (goot-listen ,@rest goot-continue))))

(defmacro goot-loop (&rest rest)
  `(while (goot-listen ,@rest goot-continue)))

(defmacro goot-for (condition increment &rest rest)
  `(while (prog1
            (and ,condition (goot-listen ,@rest goot-continue))
            ,increment)))

(defmacro goot-block (&rest rest)
  `(while (goot-listen ,@rest goot-break)))
