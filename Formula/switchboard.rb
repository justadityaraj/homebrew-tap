class Switchboard < Formula
  desc "Menu-bar browser picker that opens each link in the right browser or profile"
  homepage "https://dev.adityarajsingh.com/switchboard/"
  url "https://github.com/justadityaraj/switchboard-browser-picker/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "0655988020463ddac99acf53f6199d83d084a3aa683cfb1af23a3d229c9bb653"
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
