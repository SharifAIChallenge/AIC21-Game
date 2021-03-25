#! /bin/bash

ROOT_DIR=$PWD
LOG_PATH=$ROOT_DIR/compile.log
BIN_PATH=$ROOT_DIR/binary


# empty log file
echo "" > $LOG_PATH

# takes a string and append it to the log file as well as the console tty
function log {
  echo "$1" | tee -a $LOG_PATH
}

# generates info log
function info {
    log "===[INFO]===[`date +'%F-%T'`]=== : $1"
}
# generates warn log
function warn {
    log "===[WARN]===[`date +'%F-%T'`]=== : $1"
}
# generates FATAL log and exits with -1
function fatal {
    log "===[FATAL]==[`date +'%F-%T'`]=== : $1"
    # clean up
    rm -rf /home/isolated
    exit -1
}
# check weather or not exitcode was 0 and return
function check {
    if [ $1 -eq 0 ];then
        info "code compiled successfully!"
    else
        fatal "couldn't compile code!"
    fi
}
    

print_usage() {
  echo "compile - compiles aic2021 clients"
  echo
  echo "Usage: compile [OPTION]..."
  echo
  echo "    -l, --lang             specify the client language to compile"
  echo "                           options are:"
  echo "                           python client:        (py|python|python3|PY|PYTHON|PYTHON3)"
  echo "                           c client:             (c|cpp|C|CPP)"
  echo "                           java client:          (jar|jar) note that compile from java"
  echo "                           source is not currently available"
  echo "    -e, --entry-point      codebase entrypoint [jarfile name for java, python"
  echo "                           entrypoint for python (usually Controller.py),leave empty"
  echo "                           for cpplient]"
  echo "    -o, --output-path      where to save the resulting executable file"
  echo "                           if left empty would save at \$PWD/binary"
  echo
  echo "Example"
  echo "-------"
  echo
  echo "compile --lang py --entry-point Controller.py -o pyclient"
  echo "compile -l jar --e jclient.jar -o jar-binary"
  echo "compile -l cpp"
  
} 

# argument parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--lang)
      shift
      declare -r LANG="$1"
      shift
      ;;
    -o|--output-path)
      shift
      BIN_PATH="$1"
      shift
      ;;
    -e|--entry-point)
      shift
      declare -r ENTRYPOINT="$1"
      shift
      ;;

    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "ERROR: Unexpected option ${1}"
      echo
      print_usage
      exit 99
      ;;
  esac
done

# validation 
if [ -z "$LANG" ]; then   
  fatal "ERROR: You must set the parameter --lang"
fi

if [ -z "$ENTRYPOINT" ]; then
  warn "You must set the parameter --entry-point unless you are compiling the cpp client"
fi

BIN_PATH=`realpath $BIN_PATH`

# make an isolated aread
mkdir /home/isolated
cp -r * /home/isolated
cd /home/isolated
info "made an isolated area"

info "entered the code base"

#compile
case $LANG in

  python|py|python3|PYTHON|PY|PYTHON3)
    
    info "language detected: python"
    info "start compiling using pyinstaller"
    pyinstaller --onefile $ENTRYPOINT >>$LOG_PATH 2>&1
    check $?
    mv dist/Controller $BIN_PATH
    
    ;;

  cpp|c|C|CPP)
    info "language detected: C"
    info "start compiling using CMAKE"
    mkdir build
    cd build
    cmake .. >>$LOG_PATH 2>&1
    make >>$LOG_PATH 2>&1
    check $?
    mv client/client $BIN_PATH
    
    ;;

  java|JAVA)
    fatal "not currently supported!\n use [jar] instead"
    
    ;;

  jar|JAR)
    info "language detected: jar"
    info "start compiling using jar-stub"
    
    cat /home/.jar-stub $ENTRYPOINT > $BIN_PATH 2>> $LOG_PATH  
    check $?
    
    ;;

  bin|BIN)
    warn "no compiling needed!"
    mv `ls | head -n1` $BIN_PATH 
    ;;

  *)
    fatal "type unknown!"
    ;;
esac

chmod +x $BIN_PATH
# clean up
rm -rf /home/isolated

