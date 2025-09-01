# typed: strict
# frozen_string_literal: true

# Podsenv - CocoaPods version management tool
class Podsenv < Formula
  desc "CocoaPods version manager inspired by pyenv"
  homepage "https://github.com/wy625571185/podsenv" # Replace with your actual GitHub repo
  url "https://github.com/wy625571185/podsenv/archive/refs/tags/v0.1.0.tar.gz"
  version "0.1.0"
  sha256 "9f80f0f2b42b551c5173f1109734ae6ba786cde4d0220484ffabd3c3c9a564a2"

  depends_on "ruby"

  def install
    prefix.install "podsenv"
    prefix.install "install.sh"
    prefix.install "README.md"

    # Create symlink to podsenv executable
    bin.install_symlink prefix/"podsenv"

    # Create necessary directories for podsenv
    (prefix/".podsenv").mkpath
    (prefix/".podsenv/versions").mkpath
    (prefix/".podsenv/shims").mkpath
    (prefix/".podsenv/bin").mkpath
    (prefix/".podsenv/default_gem_home").mkpath

    # NOTE: Users will need to configure their shell to use podsenv
    # The podsenv script will use ~/.podsenv as the default root directory
  end

  def caveats
    <<~EOS
      To complete the installation, add the following to your shell's rc file (e.g., ~/.bashrc or ~/.zshrc):

        # podsenv configuration
        export PATH="$(brew --prefix podsenv)/bin:$HOME/.podsenv/shims:$PATH"
        eval "$(podsenv init -)"

      Then, restart your shell or run `source ~/.bashrc` (or your shell's rc file).

      You can then install CocoaPods versions using:
        podsenv install <version>

      For example:
        podsenv install 1.11.3
    EOS
  end

  test do
    # `test do` will create a temporary directory and run tests there.
    # We need to simulate the podsenv environment setup.
    (testpath/".podsenv").mkpath
    (testpath/".podsenv/versions").mkpath
    (testpath/".podsenv/shims").mkpath
    (testpath/".podsenv/bin").mkpath
    (testpath/".podsenv/default_gem_home").mkpath

    # Copy the podsenv script to the test environment
    cp bin/"podsenv", testpath/".podsenv/bin/podsenv"
    chmod 0755, testpath/".podsenv/bin/podsenv"

    # Simulate the shell environment setup
    ENV["PATH"] = "#{testpath}/.podsenv/bin:#{testpath}/.podsenv/shims:#{ENV.fetch("PATH", nil)}"
    system "#{testpath}/.podsenv/bin/podsenv", "init", "-"

    # Test podsenv commands
    system "#{testpath}/.podsenv/bin/podsenv", "install", "1.11.3"
    assert_match "1.11.3", shell_output("#{testpath}/.podsenv/bin/podsenv global 1.11.3 && " \
                                        "#{testpath}/.podsenv/bin/podsenv versions")
    assert_match "1.11.3", shell_output("#{testpath}/.podsenv/bin/podsenv global 1.11.3 && " \
                                        "#{testpath}/.podsenv/shims/pod --version")
  end
end
