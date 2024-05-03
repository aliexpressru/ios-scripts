#!/bin/zsh

# Gradle clean

CLEAN_TARGET=~/_repos/myGradleRepo

cd ${CLEAN_TARGET} || { echo "Wrong path"; exit 0; }
echo "🔵👉 `pwd`"

./gradlew --stop
sleep 3
echo "🔵 gradlew --stop"


ps -ef | grep gradle
echo "🔵👆 must be nothing but 'grep gradle'"


rm -rf ~/.gradle/caches
echo "🔵 rm -rf gradle caches"


./gradlew clean
echo "🔵 gradlew clean at '$(basename ${CLEAN_TARGET})'"
