@echo off

call .paket\paket restore
call packages\FSharp.Formatting.CommandTool\tools\fsformatting.exe literate --processDirectory --lineNumbers false --inputDirectory  "code" --outputDirectory "_posts"
call packages\FSharp.Formatting.CommandTool\tools\fsformatting.exe literate --processDirectory --lineNumbers false --inputDirectory  "snippets" --outputDirectory "_snippets"

git add --all .
git commit -a -m %1
git push