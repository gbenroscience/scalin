# scalin
Simple bash script to scale Linux apps horizontally

`scalin` is a simple bash script designed to allow the quick horizontal scaling of apps.
It has very few flags that allow you to control the process, too.


## Prerequisite
<b>We now support loading of environmen variables from external files before running the services. Also systemd daemon is now reloaded automatically after the orchestration. 
<b>We now support spring boot, micronaut, quarkus, jar executables and native linux executables</b>

### Spring Boot
Use the newly introduced flag -t springboot
### Micronaut
Use the newly introduced flag -t micronaut
### Quarkus
Use the newly introduced flag -t quarkus
### Jar executable
Use the newly introduced flag -t jar. This presupposes the fact that your application can receive the port number from the command line using the --port=portnumber syntax
### War executable
Use the newly introduced flag -t war. This presupposes the fact that your application can receive the port number from the command line using the --port=portnumber syntax
### Linux executable
Use the newly introduced flag -t native or ignore the flag altogether. This presupposes the fact that your application can receive the port number from the command line using the --port=portnumber syntax. The system assumes your app is a native platform executable by default.



## Installation
You may type `chmod a+x /path/to/scalin` at the terminal to make the file executable.<br>
Otherwise, you will have to use <br><br>`bash /path/to/scalin <flags>`

Optionally, to make the `scalin` command available everywhere, add it to **PATH** by doing:

`vi ~/.bash_profile` *(or use some other editor)*

Now add the following line to the file:<br>
`export PATH=$PATH:/path/to/scalin`
<br>Now save the file and then use:

`source ~/.bash_profile`


### Flags

1. *Use the `-s` flag to specify the service name*<br>
2. *Use the `-h` flag to view help*<br>
3. *Use the `-v` flag to view the status of all instances of a scaled service*<br>
4. *Use the `-k` flag to kill all instances of a scaled service*<br>
5. *Use the `-r` flag to run all instances of a scaled service*<br>
6. *Use the `-z` flag to kill and delete all instances of a scaled service*<br>
7. *Use the `-p` flag to specify the base port number*<br>
8. *Use the `-n` flag to specify the number of instances*<br>
9. *Use the `-d` flag to specify a description for the service*<br>
10. *Use the `-u` flag to specify the linux user running `scalin`*<br>
11. *Use the `-g` flag to specify the linux group running `scalin`*<br>
12. *Use the `-w` flag to specify a working directory for the instances*<br>
13. *Use the `-e` flag to specify the path to the service executable*<br>
14. *Use the `-x` flag to specify a script that you would love to run before creating and starting the instances. This was included to allow users do stuff like: pull the source code from VCS, build the executable from source, and maybe copy the executable to the path specified using the `-e` flag*
15. *Use the `-t` flag to specify the type of application being scaled. (native, quarkus, micronaut, springboot, jar, native(default)). For the jar and native types, make sure your application can receive the port number from the command line args using --port=<port_number>*
16. *Use the `-f` flag to specify a file that contains environment variables to be loaded before starting the service.*<br>


## Usage

To view `help`, type:

`scalin -h`<br>

To view the status of running services:<br>

`scalin -s <service_name> -v`<br>

To kill the running services:

`scalin -s <service_name> -k`<br>

To restart the services after killing them:

`scalin -s <service_name> -r`<br>


To destroy all instances of a created service:

`scalin -s <service_name> -z`<br>


### Service creation
To create a scaled service, use:

`scalin  -s <service_name> -p 8000 -n 4 -d "Money Making Service" -u <linux_user> -g <linux_group> -w /path/to/workingdirectory -e /path/to/executable`


1. If the `-u` flag is not set, the default user is set to `root`
2. If the `-g` flag is not set, the default group is set to `root`
3. If the `-p` flag is not set, the default base port is `8080`
4. If the `-n` flag is not set, the default number of instances is `1`
5. When running the `-v`, `-k`, `r` flags, you must supply the `-s` flag, as it tells the script what service you want to interact with. 


Make sure that when you are specifying a value for `-p`, say `P`, that all values of the ports between `P` and `P+N-1` are free. Where N is the number of instances(the value passed to the `-n` flag). 
So if you use:
`scalin -s moneymaker -p 8090 -n 5 ...`
Then the ports `8090, 8091, 8092, 8093, 8094` must be available for `scalin` to apply to your app. e.g. from `8090 - (8090+5-1)`, which is `8090 - 8094`



## NOTES
Once up and running, you can use a simple modification to put all these instances behind nginx or apache load balancers.

For `nginx`, if you have `5` server instances, and your `-p` flag is set to `8080`, add the lines to your `nginx.conf`:

```nginx
    upstream <servicename> {
      server localhost:8080 weight=10;
      server localhost:8081 weight=10;
      server localhost:8082 weight=10;
      server localhost:8083 weight=10;
      server localhost:8084 weight=10;
    }
```

Then add:   
```nginx      
    location / {
       proxy_pass http://<servicename>;
    }
```       
to your active server block
### Conclusion
*The project is still evolving and I found it useful for my work, when I dont want to install something as elaborate as docker on a bare metal server or some other use cases.*