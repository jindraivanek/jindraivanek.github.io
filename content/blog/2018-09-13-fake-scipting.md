---
title: How to run any F# script with FAKE
tags: 
  - F#
  - FAKE
  - tutorial
---

[FAKE](http://fake.build) is not only a great build DSL, but it can be used to run any F# script, while allowing to specify dependencies inside script.

### Steps to run F# script with FAKE from zero configuration:

* Install .NET Core SDK for your platform: https://www.microsoft.com/net/download
* Install FAKE global tool: `dotnet tool install fake-cli -g` (on linux `sudo dotnet tool install fake-cli -g`)
* Create `script.fsx` file with this content:
```fsharp
#r "paket: 
    nuget AwesomeLib1
    nuget AwesomeLib2"
#load ".fake/script.fsx/intellisense.fsx"
#if !FAKE
#r "netstandard"
#endif

// Your code here.
```
* Replace `AwesomeLib1` and `AwesomeLib2` with your NuGet dependencies.
* Put your code in `script.fsx`.
* Run your code with `fake run script.fsx` (`fake -s run script.fsx` for suppress FAKE output.)
* Profit!

### Notes
* `#load ".fake/script.fsx/intellisense.fsx"` line enables Intellisense support for IDE after script is runned first time (dependencies need to be downloaded).
* When you change dependencies, you need to delete `script.fsx.lock` file, to force FAKE to recompute dependencies.
* If you run into some problems, try removing `.fake/script.fsx` folder.
