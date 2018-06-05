validate_args() {

  USAGE="install.sh -a [app-name] [app tar.gz file]\ninstall.sh -c [app-id] [config tar.gz file]"

  #make sure an app name was passed in as an arugment
  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo -e $USAGE
    exit 1
  fi

  #make sure 1st arg is -a or -c
  if [[ $1 != "-c" && $1 != "-a" ]]; then
    echo -e $USAGE
    exit 1
  fi

  #make sure file exists
  if [ ! -f $3 ]; then
    echo File $3 does not exist
    exit 1
  fi
}

install_app () {

  APP=$2
  FILE=$3

  RESULT=$(curl --silent -X POST http://127.0.0.1:5000/api/v1/containers/instances -H "app_name: $APP" -H "version: 1.0"  -F "file=@/mnt/data/downloads/$3")

  UUID=$( echo "$RESULT" | jq -r '.["uuid"]' )
  ERROR=$( echo "$RESULT" | jq -r '.["error"]' )
  ERROR_MESSAGE=$( echo "$RESULT" | jq -r '.["error_message"]' )

  if [[ ! -z "$ERROR" || ! -z "$ERROR_MESSAGE" ]]; then
    echo $RESULT
    exit 1
  else

    #create the config and data folder for the app
    mkdir -p ../$UUID/config
    mkdir -p ../$UUID/data

    echo  $RESULT
  fi

}

install_config () {

  UUID=$2
  FILE=$3

  #make sure there is a config folder for the app
  mkdir -p ../$UUID/config

  #remove old config files if they exist
  rm -rf ../$UUID/config/*

  #extract new files to config folde of app
  tar -xzf $FILE -C ../$UUID/config

  #restart the app to launch with the new config files
  RESULT=$(curl --silent -X POST http://127.0.0.1:5000/api/v1/containers/instances/$UUID/stop)
  ERROR=$( echo "$RESULT" | jq -r '.["error"]' )

  if [ ! -z "$ERROR" ]; then
    echo $RESULT
    exit 1
  fi

  RESULT=$(curl --silent -X POST http://127.0.0.1:5000/api/v1/containers/instances/$UUID/start)
  ERROR=$( echo "$RESULT" | jq -r '.["error"]' )

  if [ ! -z "$ERROR" ]; then
    echo $RESULT
    exit 1
  fi

  echo $RESULT
}

validate_args $1 $2 $3

if [ $1 == "-a" ]; then
  install_app $1 $2 $3
else
  install_config $1 $2 $3
fi
