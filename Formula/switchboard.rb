class Switchboard < Formula
  desc "Menu-bar browser picker that opens each link in the right browser or profile"
  homepage "https://dev.adityarajsingh.com/switchboard/"
  url "https://github.com/justadityaraj/switchboard-browser-picker/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "5fbfcc13367cff4d21b7aa41e4570b75feeabec9f19c4e3219db9514ca5ab4d3"
  license "MIT"

  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", "Switchboard"
    system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", "SwitchboardSelfCheck"

    app = prefix/"Switchboard.app/Contents"
    (app/"MacOS").install ".build/release/Switchboard"
    app.install "Resources/Info.plist"
    (app/"Resources").install "Resources/AppIcon.icns"
    libexec.install ".build/release/SwitchboardSelfCheck"
    system "codesign", "--force", "--sign", "-", prefix/"Switchboard.app"
  end

  def caveats
    <<~EOS
      Switchboard.app is in #{opt_prefix}. Add it to Applications with:
        ln -sf "#{opt_prefix}/Switchboard.app" /Applications/Switchboard.app

      Then open Switchboard and click Make Default in its Settings.
    EOS
  end

  test do
    assert_match "All checks passed", shell_output(libexec/"SwitchboardSelfCheck")
    assert_path_exists prefix/"Switchboard.app/Contents/MacOS/Switchboard"
  end
end
