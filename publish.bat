@echo off

call build.bat

git add --all .
git commit -a -m "auto-commit"
git push