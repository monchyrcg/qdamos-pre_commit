#!/bin/bash

app="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source $app/functions.sh

############################################################
# functions                                               #
############################################################
check-php-cs-fixer() {
  echo 'Start check php-cs-fixer'

  git diff --name-only --cached | grep -e '^\(.*\).php$' | while read line; do
    case $1 in
      "local")
        echo "Run: php composer analyse --configuration phpstan.neon --memory-limit=-1"
        php composer php-cs-fixer analyse --configuration phpstan.neon --memory-limit=-1 "$line"
        ;;
      "docker")
        echo "Run: docker exec $2 composer analyse --configuration phpstan.neon --memory-limit=-1 2>/dev/null"
        docker exec $2 composer analyse --configuration phpstan.neon --memory-limit=-1 "$line" 2>/dev/null
        ;;
      \?)
        echo "Error: Invalid run type"
        exit 1;;
    esac

    git add "$line";
  done

  echo 'End check php-cs-fixer'
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
get_specific_var_environment "TYPE_EXECUTION"
run_type=$return_func
get_specific_var_environment "DOCKER_IMAGE_NAME"
image_name=$return_func

check-php-cs-fixer $run_type $image_name