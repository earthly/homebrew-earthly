class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.5.18.tar.gz"
  sha256 "b7679ae11f76536033de59c27c22ea6ca426d3e876fa61aa389d0710ac639c81"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "6ced4b644da7733596ddb225d4d07dddcdf3cea9975a1dcdce724e65093142fb"
    sha256 cellar: :any_skip_relocation, big_sur:       "45b1406d85fbc167590873e727dd63624ed17bceadc289bb4c6c7f8e8a669317"
    sha256 cellar: :any_skip_relocation, catalina:      "16c593502fd9a7270edab13a2ed8c9ca44486eb90bc97dceef99ec8c092ddadf"
    sha256 cellar: :any_skip_relocation, mojave:        "a9a09599ccebca0c987ea802cfc861097055ab2662db97c417bfeb83756fdb90"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "78f6b33643db61f1944ceaf27d27ad001f8ba7a865b358a040cf1374fd618a96"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} " \
              "-X main.GitSha=0cb24b0a8bbe4253e96990b7947e18f684918298 "
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
      \tRUN echo Homebrew
    EOS

    output = shell_output("#{bin}/earthly --buildkit-host 127.0.0.1 +default 2>&1", 6).strip
    assert_match "buildkitd failed to start", output
  end
end
