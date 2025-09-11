#!/bin/bash

PROJECT_NAME=sportsbeep-android
PACKAGE_NAME=com.sportsbeep.app.integration
PACKAGE_NAME_FOR_UIAUTOMATOR=com.sportsbeep
APK_LAUNCHABLE_ACTIVITY=com.sportsbeep.app.ui.login.LoginActivity
#Change to the java file you wish to run
JAVA_FILE_TO_RUN=SportsTestCases.java
TEST_NAME=testA_SelectSportAndProfession

if [ -f "$PROJECT_NAME.apk" ]
then
echo "Uninstalling... (1/5)"
adb uninstall $PACKAGE_NAME

echo "Installing APK... (2/5)"
adb install $PROJECT_NAME.apk

echo "Building UI Automation Tests... (3/5)"
ant build

echo "Pushing UI Tests to device... (4/5)"
adb push bin/$PROJECT_NAME-uitest.jar /data/local/tmp

echo "Running UI Tests on device... (5/5)"
#Change name to file you wish to run
for f in $(find . -name $JAVA_FILE_TO_RUN)
do
adb shell pm clear $PACKAGE_NAME
echo "Starting application..."
f=${f##*/}
CLASSNAME=${f%\.*}
adb shell am start -a android.intent.action.MAIN -n $PACKAGE_NAME/$APK_LAUNCHABLE_ACTIVITY -W

echo "Waiting 1 second to ensure the app has time to start up and come to the foreground..."
sleep 1

echo "Running tests from file $f"

echo "adb shell uiautomator runtest $PROJECT_NAME-uitest.jar -c $PACKAGE_NAME.$CLASSNAME"
#adb shell uiautomator runtest $PROJECT_NAME-uitest.jar -c $PACKAGE_NAME.$CLASSNAME
#To run a single test comment out the line above and use this line:
adb shell uiautomator runtest $PROJECT_NAME-uitest.jar -c $PACKAGE_NAME_FOR_UIAUTOMATOR.$CLASSNAME#$TEST_NAME

echo "Stopping application..."
adb shell am force-stop $PACKAGE_NAME
done

echo "UI Tests complete."
else
echo "Please put $PROJECT_NAME.apk in the root of your uitest directory (this folder)"
fi
