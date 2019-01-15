# pingtest version 0.1
<pre>
Usage pingtest [OPTION]... [FILE]
   Tries to ping a list of ip's or url's provided in a file or at command line
   and if ICMP packets are blocked (ping fails) the program will attempt
   to connect via http/s at the port specified
 
  OPTIONS:
    -f, --file      supply file name with ip's or urls to test
                    the file format is
                    
                       server-display-name | ip/url:port
                       
                    and if ping is blocked (e.g. AWS) then the test will try curl. 
    -s, --server    www.my-aws-server.com:8443
        --help      display this help and exit
        --version   display version and exit

  EXAMPLE(s):
      pingtest -f [ipfile]
      pingtest --server my-aws-server.com:8443
</pre>

An example [ipfile] called pingtest.list is included.

This is what the sample output may look like using the included example [pingtest.list](./pingtest.list) file:
<pre>
 :~$./pingtest.sh --file pingtest.list -v -m
# pingtest ver 0.1
* Github ping **passed**                                   
* Some Gateway curl and ping **failed**
* Local Printer curl and ping **failed**
* AWS server (no ping allowed) curl and ping **failed**
* google ping **passed**

5 destinations tested...

</pre>
and the because the -m (markdown) flag was used the output renders as:

# pingtest ver 0.1
* Github ping **passed**                                   
* Some Gateway curl and ping **failed**
* Local Printer curl and ping **failed**
* AWS server (no ping allowed) curl and ping **failed**
* google ping **passed**

5 destinations tested...





