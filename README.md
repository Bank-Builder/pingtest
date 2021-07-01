# pingtest version 0.2
<pre>
Usage pingtest [OPTION]... [FILE]
   Tries to ping a list of ip's or url's provided in a file or at command line
   and if ICMP packets are blocked (ping fails) the program will attempt
   to connect via http/s at the port specified
 
  OPTIONS:
    -f, --file      supply file name with ip's or urls to test
                    the file format is [server-display-name] | ip/url:port and
                    if ping is blocked (e.g. AWS) then the test will try curl. 
    -e, --email     send an on-error notification email to [email@address] when using a pingtest list
    -s, --server    pings a single server given in form [server-ip/url:port]
    -v, --verbose   display vebose details and progress bar.  Works with -f option only.
    -m, --markdown  formats the output in markdown.  Works with -v option only.
    -q, --quiet     produces no terminal output, except setting bash return value $? = 1 if failures found.
        --settings  display SMTP settings and exits
        --help      display this help and exit
        --version   display version and exit

  EXAMPLE(s):
      pingtest -f [ipfile]
      pingtest --server [server-ip/url:port]
      pingtest -f [ipfile] --email support@domain.com -q
</pre>

## Installing pingtest
A small install script is included fo convenience. To install (a) clone this repo , and (b)  just run [`./install.sh`](./install.sh).

If installed correctly, you should be greeted with
```
pingtest (bank-builder utils) version 0.2
Copyright (C) 2018-2021, Bank Builder
License MIT: https://opensource.org/licenses/MIT
```

## Usage
An example `[ipfile]` called pingtest.list is included.

This is what the sample output may look like using the included example [pingtest.list](./pingtest.list) file:
<pre>
pingtest --file pingtest.list -v -m
# pingtest ver 0.2
* Github ping **passed**                                   
* Some Gateway curl and ping **failed**
* Local Printer curl and ping **failed**
* AWS server (no ping allowed) curl and ping **failed**
* google ping **passed**

5 destinations tested...

</pre>
and the because the -m (markdown) flag was used the output renders as:

```
# pingtest ver 0.2
* Github ping **passed**                                   
* Some Gateway curl and ping **failed**
* Local Printer curl and ping **failed**
* AWS server (no ping allowed) curl and ping **failed**
* google ping **passed**

5 destinations tested...
```

## Sending notification emails
Sending of emails for unping-able destinations is enabled by adding the `--email` argument with the email address to which to sent the failure notification, as follows: `pingtest -f pingtest.list --email me@domain.com -q` where the `-q` parameter is intended for using pingtest in a CI/CD pipeline.  Any failures in the pingtest.list would result in `$? == 1`. 

You will need to configure environmental variables either in your CI/CD pipeline or your `~/.bashrc` depending on your use case. For example add these to the end of your `~/.bashrc` as follows:
```
echo "export SMTP_SERVER=smtp.office365.com" >> ~/.bashrc
```
To Determine which environment variables to configure and to check if they are correct you mat use the `pingtest --settings` command and it should yield a result similar to the following:
```
pingtest ver 0.2 SMTP settings
================================================
SMTP_SERVER=smtp.office365.com
SMTP_TIMEOUT=15 (default is 15 seconds)
SMTP_FROM_EMAIL=info@domain.com
SMTP_PORT=587
SMTP_USERNAME=info@domain.com
SMTP_ENCRYPTION_METHOD= (Options are ENFORCE_TLS | TLS | NONE)
SMTP_USESSL=true (Default is true)
SMTP_PASSWORD=
SMTP_FROM_NAME=Info
================================================
In order to use the --email option to send error notifications
the environment variables above need to be correctly set.
```
> Note: `pingtest` will never display the password field for security reasons.

This will send an email that look similar to the following:
```
From: Info <info@domain.com>
Sent: 01 July 2021 16:07
To: "Support" <support@domain.com>
Subject: Pingtest Failure
 
-----------------------

Ping Test Failed to: Local Printer
Ping Test Failed to: AWS server (no ping allowed)

Regards,
Pingtest ver 0.2
-----------------------
```


## Setting up a systemd timer to run pingtest
One possible use case for pingtest is to run a systemd timer service to periodically (every 5 minutes) run ping tests.
Remember to whitelist your server IP if you are using adaptive firewalls or `fail2ban` on the target servers you wish to monitor.

---
(c) Copyright 2021, Bank-Builder


