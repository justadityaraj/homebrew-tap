class Folderglass < Formula
  desc "Quick Look previews for folders, git repos, zip archives and Markdown"
  homepage "https://dev.adityarajsingh.com/folderglass/"
  url "https://github.com/justadityaraj/folderglass/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "44e960044490c0419148121e00dae4dbd20e5c295875ec320ba76390688b8295"
  license "MIT"

  depends_on macos: :sonoma

  def install
    %w[Folderglass FolderglassPreview FolderglassSelfCheck].each do |product|
      system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", product
    end
    bin_path = Utils.safe_popen_read("swift", "build", "--configuration", "release", "--show-bin-path")
    bin_path = Pathname(bin_path.chomp)

    app = prefix/"Folderglass.app/Contents"
    appex = app/"PlugIns/FolderglassPreview.appex/Contents"
    (app/"MacOS").install bin_path/"Folderglass"
    app.install "Resources/Info.plist"
    (app/"Resources").install "Resources/AppIcon.icns"
    (appex/"MacOS").install bin_path/"FolderglassPreview"
    appex.install "Resources/Preview-Info.plist" => "Info.plist"
    libexec.install bin_path/"FolderglassSelfCheck"
    system "codesign", "--force", "--sign", "-", "--entitlements", "Resources/Preview.entitlements",
           prefix/"Folderglass.app/Contents/PlugIns/FolderglassPreview.appex"
    system "codesign", "--force", "--sign", "-", prefix/"Folderglass.app"
  end

  def caveats
    <<~EOS
      Folderglass.app is in #{opt_prefix}. Add it to Applications and open it once
      to switch on the Quick Look extension:
        ln -sf "#{opt_prefix}/Folderglass.app" /Applications/Folderglass.app
        open /Applications/Folderglass.app

      Then select a folder in Finder and press Space.
    EOS
  end

  test do
    assert_match "All checks passed", shell_output(libexec/"FolderglassSelfCheck")
    appex = prefix/"Folderglass.app/Contents/PlugIns/FolderglassPreview.appex"
    assert_path_exists appex/"Contents/MacOS/FolderglassPreview"
  end
end
