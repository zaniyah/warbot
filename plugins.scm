(register-plugin!
 'log
 (lambda (name . conf)
   (printf "plugin log: (configure ~S)\n" conf)
   (make-plugin
    name
    (lambda ()
      (printf "plugin log: (enable)\n")
      (void))
    (lambda ()
      (printf "plugin log: (disable)\n")
      (void))
    (lambda (nick channel)
      (printf "plugin log: (join ~S ~S)\n" nick channel)
      (void))
    (lambda (nick channel)
      (printf "plugin log: (leave ~S ~S)\n" nick channel)
      (void))
    (lambda (nick channel text)
      (printf "plugin log: (speak ~S ~S ~S)\n" nick channel text)
      (void))
    '()
    '())))

(register-plugin! 'scheme
                  (lambda (name)
                    (make-plugin
                     name
                     (lambda ()
                       (void))
                     (lambda ()
                       (void))
                     (lambda (nick channel)
                       (void))
                     (lambda (nick channel)
                       (void))
                     (lambda (nick channel text)
                       (void))
                     (list
                      (make-plugin-command
                       (irregex "eval +(.*)")
                       'eval
                       "eval <scheme>: Run some arbitrary code"
                       (lambda (nick reply-to channel all message)
                         (let* ((sexpr (with-input-from-string message read))
                                (result
                                 (call-with-current-continuation
                                  (lambda (k)
                                    (with-exception-handler
                                     (lambda (exn)
                                       (k (sprintf "ERROR: ~S" exn)))
                                     (lambda ()
                                       (with-output-to-string (lambda () (write (eval sexpr))))))))))
                           (irc:say *con* result reply-to)))))
                     '())))

(register-plugin! 'clock
                  (lambda (name)
                    (make-plugin
                     name
                     (lambda () (void))
                     (lambda () (void))
                     (lambda (nick channel) (void))
                     (lambda (nick channel) (void))
                     (lambda (nick channel text) (void))
                     (list
                      (make-plugin-command
                       (irregex "time")
                       '*
                       "time: Tell the time"
                       (lambda (nick reply-to channel all)
                         (irc:say *con* (sprintf "~A: It's ~A, or ~A" nick
                                                 (time->string
                                                  (seconds->utc-time (current-seconds))
                                                  "%a %G-W%V-%w %Y-%m-%d %H:%M:%S %Z")
                                                 (time->string
                                                  (seconds->local-time (current-seconds))
                                                  "%a %G-W%V-%w %Y-%m-%d %H:%M:%S %Z"))
                                  reply-to))))
                     '())))

(register-plugin! 'talking
                  (lambda (name)
                    (make-plugin
                     name
                     (lambda () (void))
                     (lambda () (void))
                     (lambda (nick channel) (void))
                     (lambda (nick channel) (void))
                     (lambda (nick channel text) (void))
                     '()
                     (list
                      (make-plugin-command
                       (irregex "wall +(.*)")
                       'wall
                       "wall <message>: Send a message to all channels"
                       (lambda (nick reply-to channel all message)
                         (for-each
                          (lambda (channel)
                            (irc:say *con* message channel))
                          (map car *channels*))))
                      (make-plugin-command
                       (irregex "say +([^ ]+) +(.*)")
                       'say
                       "say <channel|user> <message>: Send a message"
                       (lambda (nick reply-to channel all receiver message)
                         (irc:say *con* message receiver)))))))
