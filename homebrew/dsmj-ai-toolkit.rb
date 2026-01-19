class DsmjAiToolkit < Formula
  desc "Production-quality AI toolkit for Claude Code with specialized agents and modular skills"
  homepage "https://github.com/dsantiagomj/dsmj-ai-toolkit"
  url "https://github.com/dsantiagomj/dsmj-ai-toolkit/archive/refs/tags/v2.2.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"
  version "2.2.0"

  def install
    # Install all components to libexec
    libexec.install Dir["*"]

    # Create bin wrapper
    (bin/"dsmj-ai").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/dsmj-ai" "$@"
    EOS
  end

  def caveats
    <<~EOS
      To initialize dsmj-ai-toolkit in your project:
        cd your-project
        dsmj-ai init

      For more information:
        dsmj-ai help
    EOS
  end

  test do
    system "#{bin}/dsmj-ai", "version"
  end
end
