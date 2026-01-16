class DsmjAiToolkit < Formula
  desc "AI-powered development toolkit for Claude Code"
  homepage "https://github.com/dsantiagomj/dsmj-ai-toolkit"
  url "https://github.com/dsantiagomj/dsmj-ai-toolkit/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "" # Will be filled when creating release
  license "MIT"
  version "1.0.0"

  depends_on "git"

  def install
    # Install all toolkit files
    prefix.install "agents"
    prefix.install "skills"
    prefix.install "templates"
    prefix.install "bin"
    prefix.install ".dsmj-ai" if File.directory?(".dsmj-ai")

    # Make CLI executable and create symlink
    chmod 0755, "#{prefix}/bin/dsmj-ai"
    bin.install_symlink "#{prefix}/bin/dsmj-ai"
  end

  def caveats
    <<~EOS
      dsmj-ai-toolkit has been installed!

      Next steps:
        1. Navigate to your project directory
        2. Run: dsmj-ai init
        3. Start Claude Code in your project

      For help: dsmj-ai --help
      Repository: https://github.com/dsantiagomj/dsmj-ai-toolkit
    EOS
  end

  test do
    system "#{bin}/dsmj-ai", "--version"
  end
end
