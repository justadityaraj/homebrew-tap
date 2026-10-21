class Foldout < Formula
  desc "Quick Look previews for folders, git repos, zip archives and Markdown"
  homepage "https://dev.adityarajsingh.com/foldout/"
  url "https://github.com/justadityaraj/foldout-folder-preview/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "416ffd694ae0ad326b229004ae0debd5377bb3fe1ed113f443a4649d03645b96"
  license "MIT"

  depends_on macos: :sonoma

  def install
    %w[Foldout FoldoutPreview FoldoutSelfCheck].each do |product|
      system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", product
    end
    bin_path = Utils.safe_popen_read("swift", "build", "--configuration", "release", "--show-bin-path")
    bin_path = Pathname(bin_path.chomp)

    app = prefix/"Foldout.app/Contents"
    appex = app/"PlugIns/FoldoutPreview.appex/Contents"
    (app/"MacOS").install bin_path/"Foldout"
    app.install "Resources/Info.plist"
    (app/"Resources").install "Resources/AppIcon.icns"
    (appex/"MacOS").install bin_path/"FoldoutPreview"
    appex.install "Resources/Preview-Info.plist" => "Info.plist"
    libexec.install bin_path/"FoldoutSelfCheck"
    system "codesign", "--force", "--sign", "-", "--entitlements", "Resources/Preview.entitlements",
           prefix/"Foldout.app/Contents/PlugIns/FoldoutPreview.appex"
    system "codesign", "--force", "--sign", "-", prefix/"Foldout.app"
  end

  def caveats
    <<~EOS
      Foldout.app is in #{opt_prefix}. Add it to Applications and open it once
      to switch on the Quick Look extension:
        ln -sf "#{opt_prefix}/Foldout.app" /Applications/Foldout.app
        open /Applications/Foldout.app

      Then select a folder in Finder and press Space.
    EOS
  end

  test do
    assert_match "All checks passed", shell_output(libexec/"FoldoutSelfCheck")
    assert_path_exists prefix/"Foldout.app/Contents/PlugIns/FoldoutPreview.appex/Contents/MacOS/FoldoutPreview"
  end
end
