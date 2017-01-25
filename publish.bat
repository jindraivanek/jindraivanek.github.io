@echo off

call build.bat

git add --all .
git commit -a -m %1
git push