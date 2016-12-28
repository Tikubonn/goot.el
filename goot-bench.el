
(require 'goot)

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
