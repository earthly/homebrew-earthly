class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.6.17.tar.gz"
  sha256 "4a7d0c3b27962fda52ebe77b0a32ab280a5ea4177a3ec3b1b67f2198b0f3ab8f"
  license "MPL-2.0"
  head "https://github.com/earthly/earthly.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.6.17"
    sha256 cellar: :any_skip_relocation, big_sur: "9176dfc3d13774904f7ba18616b6ce9bcfd39fd5786cfb37836a27c1a719dee2"
  end

  depends_on "go@1.17" => :build

  def install
    # the earthly_gitsha variable is required by the earthly release script, moving this value it into
    # the ldflags string will break the upstream release process.
    earthly_gitsha = "7e4f1df4c124db1644d51d312b19313217cbe478"

    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} " \
              "-X main.GitSha=#{earthly_gitsha}"
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
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
    # earthly requires docker to run; therefore doing a complete end-to-end test here is not
    # possible; however the "earthly ls" command is able to run without docker.
    (testpath/"Earthfile").write <<~EOS
      VERSION 0.6
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earthly ls")
    assert_match "+mytesttarget", output
  end
end
