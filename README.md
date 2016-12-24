# goot.el
this add some loop macros that support break/continue operators without exception oprators.

# performance

```lisp
(defun sum-faster (num)
    (let ((sum 0))
        (while (< 0 num)
            (incf sum num)
            (decf num))
        sum))

(defun sum-try-catch (num)
    (let ((sum 0))
        (while (catch 'loop
            (when (= 0 num) (throw 'loop nil))
            (incf sum num)
            (decf num)
            (throw 'loop t)))
        sum))

(defun sum-goot (num)
    (let ((sum 0))
        (goot-loop
            (when (= 0 num) goot-break)
            (incf sum num)
            (decf num)
            goot-continue)
        sum))

(print (benchmark-run 10000 (sum-faster 128)))
(print (benchmark-run 10000 (sum-try-catch 128)))
(print (benchmark-run 10000 (sum-goot 128)))
```

compiled

```lisp
(0.06407903499999999 0 0.0)
(0.21623230499999999 0 0.0) ;; using catch and throw
(0.069179176 0 0.0) ;; using goot
```

not compiled

```lisp
(0.266857461 0 0.0)
(0.46639740399999996 0 0.0) ;; using catch and throw
(0.423916996 0 0.0) ;; using goot
```