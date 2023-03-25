# scalin
Simple bash script to scale Linux apps horizontally

`scalin` is a simple bash script designed to allow the quick horizontal scaling of apps.
It has very few flags that allow you to control the process, too.




## Installation
You may type `chmod a+x /path/to/scalin` at the terminal to make the file executable.<br>
Otherwise, you will have to use <br><br>`bash /path/to/scalin <flags>`

Optionally, to make the `scalin` command available everywhere, add it to PATH by doing:

`vi ~/.bash_profile` *(or use some other editor)*

Now add the following line to the file:<br>
`export PATH=$PATH:/path/to/scalin`
<br>Now save the file and then use:
 
`source ~/.bash_profile`


### Flags

***Use the `-h` flag to view help<br>
Use the `-v` flag to view the status of all instances of a scaled service<br>
Use the `-k` flag to kill all instances of a scaled service<br>
Use the `-r` flag to run all instances of a scaled service<br>
Use the `-s` flag to specify the service name<br>
Use the `-p` flag to specify the base port name<br>
Use the `-n` flag to specify the number of instances<br>
Use the `-d` flag to specify a description for the service<br>
Use the `-u` flag to specify the linux user running `scalin`<br>
Use the `-g` flag to specify the linux group running `scalin`<br>
Use the `-w` flag to specify a working directory for the instances<br>
Use the `-e` flag to specify the path to the service executable<br>***


## Usage

To view `help`, type:

`scalin -h`<br>

To view the status of running services:<br>

`scalin -s <service_name> -v`<br>

To kill the running services:

`scalin -s <service_name> -k`<br>

To restart the services after killing them:

`scalin -s <service_name> -r`<br>






### Service creation
To create a scaled service, use:

`scalin  -s <service_name> -p 8000 -n 4 -d "Money Making Service" -u <linux_user> -g <linux_group> -w /path/to/workingdirectory -e /path/to/executable`


### Conclusion
The project is still evolving and I found it useful for my work, when I dont want to install something as elaborate as docker on a bare metal server or some other use cases.