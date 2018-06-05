package_files () {

  FOLDER=$1
  FILE=$FOLDER.tar.gz

  if [[ "$FOLDER" != "app" && "$FOLDER" != "config" ]]; then
    echo "usage: package.sh [app|config]"
    exit 1
  fi

  #if folder does not exist - exit
  if [ -d "$FOLDER" ]; then

    echo Packaging the $FOLDER

    #remove old tar file
    if [ -f "$FILE" ]; then
      rm -f $FILE
    fi

    #create new tar file from app folder contents and remove the folder
    tar -czvf $FILE -C $FOLDER .
    rm -r $FOLDER
    echo $FOLDER packaged

  else
    echo $FOLDER folder does not exist - there is nothing to package
  fi
}

#package the app
package_files $1
