class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.5.24.tar.gz"
  sha256 "50599a24502f7f3bc287c931676ba2ef5f70ba567233b848b0560e360190ef94"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.5.23"
    sha256 cellar: :any_skip_relocation, catalina:     "51a2d676def4b6809a0c00caf5e256f0cdcd91146b698a039900fed7dcc8f6d9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "5ed115f52074a8d3399c660566c3ad2d77ee9d1c0a0e99a570c5b36a0d316e34"
  end

  depends_on "go@1.16" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=68e0565ae0adef1f0b4711a18f797684525fc9e8 "
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc"
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

    output = shell_output("#{bin}/earthly --version").strip
    assert output.start_with?("earthly version")
  end
end
