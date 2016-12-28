# goot.el

this provide some loop macros that support break/continue operators without exception oprators.

# provide macros

there are faster than using `catch/throw` exception.
but, there are has some limitation.

1. `goot-break` and `goot-continue` should place on the last of list.
1. `goot-break` and `goot-continue` dont place in the some functions argument (not progn if and or ... ).

* `(goot-break)`
    * this transform to symbol of `goot-break`. `goot-break` use to hint to the transforming in internal macro of `goot-listen`.
* `(goot-continue)`
    * this transform to symbol of `goot-continue`. `goot-continue`use to hint to the transforming in internal macro of `goot-listen`.
* `(goot-forever &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-while condition &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was failed. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-until condition &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was successed. you can repeat this section from the beginning with using `goot-continue` oprator.
* `(goot-for condition increment &rest body)`
    * this evaluate *body* section forever, until to reach the `goot-break`, or *condition* was failed. you can repeat this section from the beginning with using `goot-continue` oprator. *increment* is evaluate always at end of loop.
* `(goot-block &rest body)`
    * this evaluate *body* section one times. you can repeat or abort this section with `goot-break' or `goot-continue' oprators.

# provide optimized macros

there are little faster than other macros in goot.el.
but, there has more limitation.

* `(goot-forevermad &rest body)`
    * same as `goot-forever`
* `(goot-whilemad condition &rest body)`
    * same as `goot-while`
* `(goot-untilmad condition &rest body)`
    * same as `goot-until`
* `(goot-formad condition increment &rest body)`
    * same as `goot-for`
* `(goot-blockmad &rest body)`
    * same as `goot-block`

# performance

```lisp
(cl-labels
  
  ((benchmark-sum-while (num)
     (let ((sum 0))
       (while (/= num 0)
         (incf sum num)
         (decf num))
       sum))
    
    (benchmark-sum-forevermad (num)
      (let ((sum 0))
        (goot-forevermad
          (if (= num 0) (goot-break))
          (incf sum num)
          (decf num)
          (goot-continue))
        sum))
    
    (benchmark-sum-forever (num)
      (let ((sum 0))
        (goot-forever
          (if (= num 0) (goot-break))
          (incf sum num)
          (decf num)
          (goot-continue))
        sum))
    
    (benchmark-sum-catch/throw (num)
      (let ((sum 0))
        (while (catch 'loop
                 (if (= num 0) (throw 'loop nil))
                 (incf sum num)
                 (decf num)
                 (throw 'loop t)))
        sum)))
  
  (let*
    ((benchmarked-sum-while (car (benchmark-run 1000 (benchmark-sum-while 1000))))
      (benchmarked-sum-forevermad (car (benchmark-run 1000 (benchmark-sum-forevermad 1000))))
      (benchmarked-sum-forever (car (benchmark-run 1000 (benchmark-sum-forever 1000))))
      (benchmarked-sum-catch/throw (car (benchmark-run 1000 (benchmark-sum-catch/throw 1000)))))        
    (message "%f sec spended. (while only)" benchmarked-sum-while)
    (message "%f sec spended. (goot-forevermad)" benchmarked-sum-forevermad)
    (message "%f sec spended. (goot-forever)" benchmarked-sum-forever)
    (message "%f sec spended. (catch/throw)" benchmarked-sum-catch/throw)         
    (message "%d%% faster than catch/throw. (while only)" (- 100 (* 100 (/ benchmarked-sum-while benchmarked-sum-catch/throw))))
    (message "%d%% faster than catch/throw. (goot-forevermad)" (- 100 (* 100 (/ benchmarked-sum-forevermad benchmarked-sum-catch/throw))))
    (message "%d%% faster than catch/throw. (goot-forever)" (- 100 (* 100 (/ benchmarked-sum-forever benchmarked-sum-catch/throw))))
    (message "%d%% faster than catch/throw. (catch/throw)" (- 100 (* 100 (/ benchmarked-sum-catch/throw benchmarked-sum-catch/throw))))))
```

## not compiled

| while only | goot-forevermad | goot-forever | catch/throw |
| --- | --- | --- | --- |
| 0.251511 sec | 0.277954 sec | 0.332029 sec | 0.372102 sec |
| --- | --- | --- | --- |
| 45% faster | 25% faster | 10% faster | 0% faster |

## compiled

| while only | goot-forevermad | goot-forever | catch/throw |
| --- | --- | --- | --- |
| 0.045474 sec | 0.045242 sec | 0.053141 sec | 0.167039 sec |
| --- | --- | --- | --- |
| 72% faster | 72% faster | 68% faster | 0% faster |
