class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.5.19.tar.gz"
  sha256 "0841c0e67fe8102fcbfc4fad8d87dafbcf1de775e5991aa931222b8791ca00b6"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.5.19"
    sha256 cellar: :any_skip_relocation, catalina:     "0bd98dd115bddfa468b0718d7293f3bd9539d22b5aab9265c603ee6b85e5ce4d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "edfa89148545a71ca40ca0d5c98d57cc7d16cfad88ff7a81b56ff35b86cc20d4"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} " \
              "-X main.GitSha=e37f7a5687511930040659a509e048e314d9a6a1 "
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork"
    system "go", "build",
        "-tags", tags,
        "-ldflags", ldflags,
        *std_go_args,
        "./cmd/earthly/main.go"

    bash_output = Utils.safe_popen_read("#{bin}/earthly", "bootstrap", "--source", "bash")
    (bash_completion/"earthly").write bash_output
    zsh_output = Utils.safe_popen_read("#{bin}/earthly", "bootstrap", "--source", "zsh")
    (zsh_completion/"_earthly").write zsh_output
  end

  test do
    (testpath/"build.earthly").write <<~EOS

      default:
      \tRUN echo homebrew-earthly
    EOS

    output = shell_output("#{bin}/earthly --buildkit-host 127.0.0.1 +default 2>&1", 6).strip
    assert_match "buildkitd failed to start", output
  end
end
