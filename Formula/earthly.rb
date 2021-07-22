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
    root_url "https://github.com/earthly/earthly/archive/v0.5.19.tar.gz"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina:     "45460a8adb85ad67bfaf58fd54cf0f7519c52eb85032ffac70a9c20e90ec8b0f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0604bc83c6c79762549be7ce226a209cc58cdaf63c81c3e983f380ee0c8e92f9"
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
