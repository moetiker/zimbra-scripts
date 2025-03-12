# zimbra-scripts
Scripts for zimbra helping me during the Administration day

- restart-mysql-imap-bug.sh
  
  A bug in Zimbra 8.8.15 triggers a huge SELECT command in the MySQL database during iOS IMAP requests. Restarting the MySQL database resolves the problem.
