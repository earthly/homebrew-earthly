# homebrew-earthly

This repository contains the homebrew formula required to install `earthly` on MacOS via `brew`.

To install earthly on MacOS, run:

```
brew install earthly/earthly/earthly && earthly bootstrap
```

As described on the [get earthly](https://earthly.dev/get-earthly) page.

## FAQ

### What's the difference between homebrew-core and earthly/earthly/earthly

If you run `brew install earthly`, you will install the version from [homebrew-core](https://github.com/homebrew/homebrew-core), which is controlled by the homebrew community.

Instead, it's recommended to install earthly from the earthly tap, which is maintained by earthly, and is part of the official earthly release process. This means near-zero delay between propigating a [binary release](https://github.com/earthly/earthly/releases) to the tap. Releases to the homebrew-core tap, on the otherhand, must be approved by the homebrew-core maintainers which introduces delay.
