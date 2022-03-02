class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.6.9.tar.gz"
  sha256 "a0ca43985cda4f7ff4da8943858a52b052dae3054b2820a780c0e89bd94f8861"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.6.8"
    sha256 cellar: :any_skip_relocation, big_sur: "83e574a95f60279190aba9929bad8a011af8ab84d24cd577b481289edf8bcf54"
  end

  depends_on "go@1.17" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=92cb87bbd28f806aeb9ba300d22e4bdd38dba18c "
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
    (testpath/"build.earthly").write <<~EOS

      default:
      \tRUN echo homebrew-earthly
    EOS

    output = shell_output("#{bin}/earthly --version").strip
    assert output.start_with?("earthly version")
  end
end
