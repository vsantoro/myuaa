FOLDER=$1
IMAGES_FILE="images.tar"
DOCKER_COMPOSE="docker-compose.yml"

#if app folder does not exist - exit
if [ -z "$FOLDER" ]; then
  echo "usage: refresh.sh [folder]"
  exit 1
fi

#if app folder does not exist - exit
if [ ! -d "$FOLDER" ]; then
  echo folder $1 does not exist
  exit 1
fi

if [ ! -f "$FOLDER/$DOCKER_COMPOSE" ]; then
  echo there is no $DOCKER_COMPOSE file in $FOLDER
  exit 1
fi

#remove the old images file
if [ -f "$FOLDER/$IMAGES_FILE" ]; then
  rm -f $FOLDER/$IMAGES_FILE
fi

#get list of images form docker-compose
IMAGE_LIST=$(cat $1/$DOCKER_COMPOSE | grep image: | grep -v \#image | sed 's/image://g ; s/\"//g ; s/ //g')

#pull the latest images into the local repository
for x in $IMAGE_LIST;
  do
      C="docker pull $x";
      ($C);
done;

if [ ! -z "$IMAGE_LIST" ]; then
  SAVE="docker save $IMAGE_LIST -o $FOLDER/$IMAGES_FILE"
  ($SAVE)
else
  echo "there are no images in the $FOLDER/$DOCKER_COMPOSE"
  exit 1
fi
