#! /usr/bin/env bash

### Configure these environment variables to point to your local installations.
###
### The functional tests require conditional values, so keep this style:
###
### test -z "$JAVA_HOME" && export JAVA_HOME=/usr/lib/jvm/java
###
### Note that the -Xmx -Xms settings below require substantial free memory:
### you may want to use smaller values, especially when running everything
### on a single machine.
###
if [[ -z $HADOOP_HOME ]] ; then
   test -z "$HADOOP_PREFIX"      && export HADOOP_PREFIX=/path/to/hadoop
else
   HADOOP_PREFIX="$HADOOP_HOME"
   unset HADOOP_HOME
fi

# hadoop-2.0:
test -z "$HADOOP_CONF_DIR"       && export HADOOP_CONF_DIR=/usr/local/hadoop-2.7.3/etc/hadoop
test -z "$JAVA_HOME"             && export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
test -z "$ZOOKEEPER_HOME"        && export ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.9
test -z "$ACCUMULO_LOG_DIR"      && export ACCUMULO_LOG_DIR=/app/hduser/accumulo/logs

if [[ -f ${ACCUMULO_CONF_DIR}/accumulo.policy ]]
then
   POLICY="-Djava.security.manager -Djava.security.policy=${ACCUMULO_CONF_DIR}/accumulo.policy"
fi
test -z "$ACCUMULO_TSERVER_OPTS" && export ACCUMULO_TSERVER_OPTS="${POLICY} -Xmx768m -Xms768m "
test -z "$ACCUMULO_MASTER_OPTS"  && export ACCUMULO_MASTER_OPTS="${POLICY} -Xmx256m -Xms256m"
test -z "$ACCUMULO_MONITOR_OPTS" && export ACCUMULO_MONITOR_OPTS="${POLICY} -Xmx128m -Xms64m"
test -z "$ACCUMULO_GC_OPTS"      && export ACCUMULO_GC_OPTS="-Xmx128m -Xms128m"
test -z "$ACCUMULO_SHELL_OPTS"   && export ACCUMULO_SHELL_OPTS="-Xmx256m -Xms64m"
test -z "$ACCUMULO_GENERAL_OPTS" && export ACCUMULO_GENERAL_OPTS="-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -Djava.net.preferIPv4Stack=true -XX:+CMSClassUnloadingEnabled"
test -z "$ACCUMULO_OTHER_OPTS"   && export ACCUMULO_OTHER_OPTS="-Xmx256m -Xms64m"
test -z "${ACCUMULO_PID_DIR}"    && export ACCUMULO_PID_DIR="${ACCUMULO_HOME}/run"
# what do when the JVM runs out of heap memory
export ACCUMULO_KILL_CMD='kill -9 %p'

### Optionally look for hadoop and accumulo native libraries for your
### platform in additional directories. (Use DYLD_LIBRARY_PATH on Mac OS X.)
### May not be necessary for Hadoop 2.x or using an RPM that installs to
### the correct system library directory.
# export LD_LIBRARY_PATH=${HADOOP_PREFIX}/lib/native/${PLATFORM}:${LD_LIBRARY_PATH}

# Should the monitor bind to all network interfaces -- default: false
# export ACCUMULO_MONITOR_BIND_ALL="true"

# Should process be automatically restarted
# export ACCUMULO_WATCHER="true"

# What settings should we use for the watcher, if enabled
export UNEXPECTED_TIMESPAN="3600"
export UNEXPECTED_RETRIES="2"

export OOM_TIMESPAN="3600"
export OOM_RETRIES="5"

export ZKLOCK_TIMESPAN="600"
export ZKLOCK_RETRIES="5"

# The number of .out and .err files per process to retain
# export ACCUMULO_NUM_OUT_FILES=5

export NUM_TSERVERS=1

### Example for configuring multiple tservers per host. Note that the ACCUMULO_NUMACTL_OPTIONS
### environment variable is used when NUM_TSERVERS is 1 to preserve backwards compatibility.
### If NUM_TSERVERS is greater than 2, then the TSERVER_NUMA_OPTIONS array is used if defined.
### If TSERVER_NUMA_OPTIONS is declared but not the correct size, then the service will not start.
###
### export NUM_TSERVERS=2
### declare -a TSERVER_NUMA_OPTIONS
### TSERVER_NUMA_OPTIONS[1]="--cpunodebind 0"
### TSERVER_NUMA_OPTIONS[2]="--cpunodebind 1"