class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.6.29.tar.gz"
  sha256 "0e7c0ae59799a27702fef100522425b56e36bb800b517c6c91107142a3c9a1e8"
  license "MPL-2.0"
  head "https://github.com/earthly/earthly.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.6.28"
    sha256 cellar: :any_skip_relocation, big_sur: "b8f2b0f1a93bb6eaa9bd77c9709d08a45f370e1a2872e9650830f4cd7d205340"
  end

  depends_on "go@1.19" => :build

  def install
    # the earthly_gitsha variable is required by the earthly release script, moving this value it into
    # the ldflags string will break the upstream release process.
    earthly_gitsha = "7e4f1df4c124db1644d51d312b19313217cbe478"

    ldflags = "-X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=1e00ed63cd506d1b017cb761a2b8d63b66dc2f23 " \
              "-X main.GitSha=#{earthly_gitsha}"
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
    system "go", "build",
        "-tags", tags,
        "-ldflags", ldflags,
        *std_go_args,
        "./cmd/earthly"

    generate_completions_from_executable(bin/"earthly", "bootstrap", "--source", shells: [:bash, :zsh])
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
