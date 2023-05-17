---
layout: layouts/post.njk
eleventyNavigation:
  key: Snippets
  order: 5
---

# Snippets

## Performance testing with Expecto

```fsharp
test "perf test" { 
    let seed = Random.mkStdGen 0L
    let xs = 
        FsCheck.Arb.generate<'a> |> FsCheck.Gen.eval 1000 seed
    Expect.isFasterThan (fun() -> optimizedFun xs |> ignore) (fun () -> originalFun xs |> ignore) ""
}
```

## Memoize disposable

```fsharp
/// Memoize that invalidate cache of disposed object. Function checkF must be operation that crash on disposed object.
let memoizeDisposableBy (f: 'a -> 'b) (g: 'a -> 'c) checkF =
    let cache = System.Collections.Concurrent.ConcurrentDictionary<_, _>(HashIdentity.Structural)
    let rec get x =
        let y = cache.GetOrAdd(Some (g x), lazy (f x)).Force()
        try checkF y |> ignore; y
        with :? ObjectDisposedException -> cache.TryRemove(Some (g x)) |> ignore; get x
    get
```

## Password encryption

Password encryption to be used in deploy scripts, so that we can safely share them.

```fsharp
#r "System.Security"

/// Generate random key and save it into "secretkey" file. This file serve as master key for password encryption, don't share it!
let initCrypto() =
    let rng = new System.Security.Cryptography.RNGCryptoServiceProvider()
    let entropy : byte[] = Array.zeroCreate 20
    rng.GetBytes(entropy)
    System.IO.File.WriteAllBytes("secretkey", entropy)

//initCrypto() // to be run once on target machine

/// Encrypt password, return string in Base64 format. This must be runned in same machine under same user as decrypt function.
let encrypt (x: string) =
    let entropy = System.IO.File.ReadAllBytes("secretkey")
    let bytes = System.Security.Cryptography.ProtectedData.Protect(System.Text.Encoding.ASCII.GetBytes x, entropy, System.Security.Cryptography.DataProtectionScope.CurrentUser)
    bytes |> System.Convert.ToBase64String

/// Decrypt password from encrypted string in Base64 format.
let decrypt (x: string) =
    let entropy = System.IO.File.ReadAllBytes("secretkey")
    let bytes = x |> System.Convert.FromBase64String
    let decryptedBytes = System.Security.Cryptography.ProtectedData.Unprotect(bytes, entropy, System.Security.Cryptography.DataProtectionScope.CurrentUser)
    System.Text.Encoding.ASCII.GetString decryptedBytes
```

## FsPickler

FsPickler can be used to "serialize" functions: 

``` fsharp
open MBrace.FsPickler
open MBrace.FsPickler.Json

let s = FsPickler.CreateJsonSerializer()
let pickle = s.PickleToString (fun x -> x + 1)
let f:int->int = bs.UnPickleOfString pickle
f(1)
```

## Memoize recursive

```fsharp
let memoize (f: 'a -> 'b) =
    let cache = System.Collections.Concurrent.ConcurrentDictionary<_, _>(HashIdentity.Structural)
    fun x ->
        cache.GetOrAdd(x, lazy (f x)).Force()

// This works, but emit warning: This and other recursive references to the object(s) being defined 
// will be checked for initialization-soundness at runtime through the use of a delayed reference.
let rec fib' = memoize <| fun n -> if n<1 then 1 else fib' (n-1) + fib' (n-2)
```
Memoize [gif](https://video.twimg.com/tweet_video/C4pJCWzUkAE-kQV.mp4) by [F# Casts](https://twitter.com/FSharpCasts)

```fsharp
let memoizeRec f =
    let cache = System.Collections.Concurrent.ConcurrentDictionary<_, _>(HashIdentity.Structural)
    let rec memF x = 
        cache.GetOrAdd(x, lazy (f memF x)).Force()
    memF
    
let fib = memoizeRec <| fun f n -> if n<1 then 1 else f (n-1) + f (n-2)
```

## Memoize

```fsharp
let memoizeBy (f: 'a -> 'b) (g: 'a -> 'c) =
    let cache = System.Collections.Concurrent.ConcurrentDictionary<_, _>(HashIdentity.Structural)
    fun x ->
        cache.GetOrAdd(Some (g x), lazy (f x)).Force()
        
let inline memoize f = memoizeBy f id
let inline memoizeConst f =
    let g = memoize (fun _ -> f())
    fun () -> g 0
```