class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.6.24.tar.gz"
  sha256 "22e804c911ba64df4dec3768e726dcc67db92bfc5cb3f559dbf3a2a63ea0b0af"
  license "MPL-2.0"
  head "https://github.com/earthly/earthly.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.6.22"
    sha256 cellar: :any_skip_relocation, big_sur: "81b3867a5250b53c37b3fa52072f61025bf67513829120bba680fa5f7a360688"
  end

  depends_on "go@1.17" => :build

  def install
    # the earthly_gitsha variable is required by the earthly release script, moving this value it into
    # the ldflags string will break the upstream release process.
    earthly_gitsha = "7e4f1df4c124db1644d51d312b19313217cbe478"

    ldflags = "-X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=20339818277375d1addc9cc20066a9890483761e " \
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
