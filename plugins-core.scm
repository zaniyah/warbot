
(register-plugin! 'user-management
		  (lambda (name allow-new-users? new-user-powers)
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
		     '()
		     (list
		      (make-plugin-command
		       (irregex "set-password +([^ ]*)")
		       '*authenticated
		       "set-password <password>: Reset your password"
		       (lambda (nick reply-to channel all password)
			 (let* ((nick* (get-nick nick))
				(user (nick-authenticated-user nick*)))
			   (user-password-set! user password)
			   (save-database!))))

		      (make-plugin-command
		       (irregex "register +([^ ]+) +([^ ]*)")
		       (if allow-new-users? '* #f)
		       "register <username> <password>: Register a new account"
		       (lambda (nick reply-to channel all username password)
			 (if (get-user username)
			     (begin
			       (irc:say *con* "I'm sorry, a user with that name already exists!" reply-to))
			     (let* ((nick* (get-nick nick))
				    (new-user
				     (make-user username
						password
						new-user-powers
						'())))
				 (nick-authenticated-user-set! nick* new-user)
				 (irc:say *con* (sprintf "Welcome, ~A" username) reply-to)
				 (set! *users* (cons (cons username new-user) *users*))
				 (save-database!)))))))))
