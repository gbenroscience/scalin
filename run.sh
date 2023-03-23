#!/bin/bash

APP_DIR=$(pwd)
# mkdir -p ${APP_DIR}

servicePathLines=''
serviceNameLines=''

basePort=8080
instances=1
desc='Example scalin service'
service='scalin'
user='root'
group='root'
workingDir=${APP_DIR}
execPath=${workingDir}/main
# path to a script that will be run before running commands that create services.
preRun='xxx'
status="xxx"
kill="xxx"
run="xxx"
help='xxx'

# NEWLINE=$'\n'
NEWLINE='
'
print_usage() {
  printf "Usage: Do bash run.sh -h to view help"
}

while getopts p:n:d:s:u:g:w:e:x:vkrh flag; do
    case "${flag}" in
        p) basePort=${OPTARG};;
        n) instances=${OPTARG};;
        d) desc=${OPTARG};;
        s) service=${OPTARG};;
        u) user=${OPTARG};;
        g) group=${OPTARG};;
        w) workingDir=${OPTARG};;
        e) execPath=${OPTARG};;
        x) preRun=${OPTARG};;
        v) status=${OPTARG};;
        k) kill=${OPTARG};;
        r) run=${OPTARG};;
        h) help=${OPTARG};;
        *) print_usage
        exit 1 ;;
    esac
done

if [ "$help" = "" ]; then
echo 'HELP:'
echo 'Use the -p flag to specify the base port number.(DEFAULT ${basePort})'
echo 'Use the -n flag to specify the number of instances to create.(DEFAULT ${instances})'
echo 'Your instances will be spread on ports ranging from the supplied or default value up to (base+instances-1)'
echo 'Use the -s flag to supply a name for the service being scaled.'
echo 'Use the -d flag to supply a description for the service being scaled.'
echo 'Use the -u flag to specify the linux user that is running the services.'
echo 'Use the -g flag to specify the linux group that is running the services.'
echo 'Use the -w flag to specify the working directory for the service.'
echo 'Use the -e flag to specify the path to the executable for the service'
echo 'Use the -x flag to specify the path to a script that should be run before executing commands that create services'

preRun
echo 'Use the -v flag to show the status for the services when installed'
echo 'Use the -k flag to kill the services'
echo 'Use the -r flag to run the pre-created services'
echo 'Use the -h flag to show the help for this tool'
echo "If the -w flag is not available, the current directory of this script will be taken as the working directory and the executable's path will be ${WORK_DIR}/main"
echo "Hence, if you do not wish to supply these flags, just put your executable file in the same directory as this script and you will be fine"
exit 0
fi


# store the names of the services here
serviceNamesRegistry=${APP_DIR}/.services.ser

# store the full paths to the services here
servicePathRegistry=${APP_DIR}/.registry.ser

# User just wishes to check the status of the instances
if [ "$status" = "" ] ; then
echo "Check status of all instances"
if [ -f "$serviceNamesRegistry" ]; then
    while IFS="" read -r p || [ -n "$p" ]
do
  echo "Instance $p"
  
  if systemctl status ${p}; then
   echo "status check success"
  else
   echo "status check failed"
   exit 1
  fi

done < ${serviceNamesRegistry}
exit 0
else 
    echo "No status to check"
        exit 1
fi
fi

# User just wishes to kill the instances
if [ "$kill" = "" ] ; then
echo "Kill all instances"
if [ -f "$serviceNamesRegistry" ]; then
    while IFS="" read -r p || [ -n "$p" ]
do
  echo "Instance $p"
  
  if systemctl stop ${p}; then
   echo "stopped $p successfully"
  else
   echo "couldn't stop $p"
   exit 1
  fi
done < ${serviceNamesRegistry}
exit 0
else 
    echo "No instance to kill"
        exit 1
fi
fi

# User just wishes to start the existing instances
if [ "$run" = "" ] ; then
echo "Restart all instances"
if [ -f "$serviceNamesRegistry" ]; then
    while IFS="" read -r p || [ -n "$p" ]
do
  echo "Instance $p"
  if systemctl restart ${p}; then
   echo "started $p successfully"
  else
   echo "couldn't start $p"
   exit 1
  fi
done < ${serviceNamesRegistry}
exit 0
else 
    echo "No instance to start"
        exit 1
fi
fi


echo "destroy and delete all running instances"
# Destroy, delete and recreate all instances
# loop through services in servicePathRegistry, shut them down, and disable them(stop startup on boot)
if [ -f "$serviceNamesRegistry" ]; then
    echo "$serviceNamesRegistry exists."
    while IFS="" read -r p || [ -n "$p" ]
     do
     printf '%s\n' "$p"

  if systemctl stop ${p}; then
   echo "stopped $p successfully"
  else
   echo "couldn't stop $p"
   exit 1
  fi

  if systemctl disable ${p}; then
   echo "disabled(start on boot) $p successfully"
  else
   echo "couldn't disable(start on boot) for $p "
   exit 1
  fi


  
done < ${serviceNamesRegistry}
else 
    echo "${serviceNamesRegistry} does not exist."
fi

# delete the serviceNamesRegistry
  if rm -f ${serviceNamesRegistry}; then
   echo "deleted service names registry successfully"
  else
   echo "couldn't delete the service names registry"
   exit 1
  fi


# Now delete all the service entries in /etc/systemd/system/
if [ -f "$servicePathRegistry" ]; then
    echo "$servicePathRegistry exists."
    while IFS="" read -r p || [ -n "$p" ]
     do
     printf '%s\n' "$p"
     echo "deleting service ${p}"
     rm -f ${p}
  
done < ${servicePathRegistry}
else 
    echo "${servicePathRegistry} does not exist."
fi
# delete the service servicePathRegistry


  if rm -f ${servicePathRegistry}; then
   echo "deleted service paths registry successfully"
  else
   echo "couldn't delete the service paths registry"
   exit 1
  fi

echo 'run user-specified tasks'

if [ $preRun != "" ] ; then
# task exists
if source $preRun; then
echo 'user-specified scripts completed successfully'
else
echo 'user-specified scripts failed'
exit 1
fi
fi

echo "create ${instances} fresh instances"
# create new services and register them. Also start them all.
endPort=$(($basePort + $instances - 1))
lastInst=$(($instances - 1))
for (( i=0; i<$instances; i++ ))
do 
port=$(($basePort + $i))
fileName=${service}${port}.service
path=/etc/systemd/system/${fileName}
   echo "Will deploy instance at ${path}"
cat <<EOF> ${path}
[Unit]
Description=${desc} on ${port}
After=multi-user.target
[Service]
User=${user}
Group=${group}
WorkingDirectory=${workingDir}
ExecStart=${execPath} --port=${port}
[Install]
WantedBy=multi-user.target
EOF
systemctl enable ${fileName}
systemctl start ${fileName}
systemctl status ${fileName}
echo "setup and running ${fileName} service"
 servicePathLines+=${path}
 serviceNameLines+=${fileName}
 if [ $i -lt $lastInst ]; then
 servicePathLines+=$NEWLINE
 serviceNameLines+=$NEWLINE
 fi
 
done

# record each entry in array on a new line in the servicePathRegistry file

echo "${servicePathLines}"
echo "${serviceNameLines}"

cat <<EOF> ${servicePathRegistry}
${servicePathLines}
EOF

cat <<EOF> ${serviceNamesRegistry}
${serviceNameLines}
EOF

echo "All's well that ends well"