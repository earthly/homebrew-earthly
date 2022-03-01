# homebrew-earthly

This repository contains the homebrew formula required to install `earthly` on MacOS via `brew`.

To install earthly on MacOS, run:

```
brew install earthly/earthly/earthly && earthly bootstrap
```

As described on the [get earthly](https://earthly.dev/get-earthly) page.

## FAQ

### Why does brew install return an `incompatible license` error

If you run `brew install earthly`, you will get the following error:

```
Error: earthly has been disabled because it has an incompatible license!
```

This is because the [version](https://github.com/Homebrew/homebrew-core/blob/master/Formula/earthly.rb) of earthly in homebrew's main homebrew-core repo is obsolete. Instead, you must run:

```
brew install earthly/earthly/earthly && earthly bootstrap
```
