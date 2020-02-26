#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.2.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/ggj-2020.x86_64 -v
echo "EXPORTING FOR OSX"
echo "-----------------------------"
godot --export "Mac OSX" build/osx/ggj-2020.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export "Windows Desktop" build/win/ggj-2020.exe -v
echo "-----------------------------"

echo "CHANGING FILETYPE FOR OSX"
echo "-----------------------------"
mv build/osx/ggj-2020.dmg build/osx/ggj-2020-osx-alpha.zip

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/ggj-2020:linux-alpha
butler push build/osx/ synsugarstudio/ggj-2020:osx-alpha
butler push build/win/ synsugarstudio/ggj-2020:win-alpha
