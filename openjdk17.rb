class Openjdk17 < Formula
  desc "Development kit for the Java programming language"
  homepage "https://openjdk.java.net/"
  if Hardware::CPU.arm?
    # Temporarily use a openjdk 17 preview on Apple Silicon
    # (because it is better than nothing)
    url "https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_macos-aarch64_bin.tar.gz"
    sha256 "b5bf6377aabdc935bd72b36c494e178b12186b0e1f4be50f35134daa33bda052"
    version "17.0.0rc"
  else
  end
  license "GPL-2.0-only" => { with: "Classpath-exception-2.0" }

  depends_on "autoconf" => :build
  depends_on xcode: :build if Hardware::CPU.arm?

  fails_with gcc: "5"

  # From https://jdk.java.net/archive/
  resource "boot-jdk" do
    on_macos do
      if Hardware::CPU.arm?
        url "https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_macos-aarch64_bin.tar.gz"
        sha256 "b5bf6377aabdc935bd72b36c494e178b12186b0e1f4be50f35134daa33bda052"
      else
      end
    end
  end

  def install
    boot_jdk = Pathname.pwd/"boot-jdk"
    resource("boot-jdk").stage boot_jdk
    on_macos do
      boot_jdk /= "Contents/Home"
    end
    java_options = ENV.delete("_JAVA_OPTIONS")

    args = %W[
      --disable-warnings-as-errors
      --with-boot-jdk-jvmargs=#{java_options}
      --with-boot-jdk=#{boot_jdk}
      --with-debug-level=release
      --with-jvm-variants=server
      --with-native-debug-symbols=none
      --with-vendor-bug-url=#{tap.issues_url}
      --with-vendor-name=#{tap.user}
      --with-vendor-url=#{tap.issues_url}
      --with-vendor-version-string=#{tap.user}
      --with-vendor-vm-bug-url=#{tap.issues_url}
      --with-version-build=#{revision}
      --without-version-opt
      --without-version-pre
    ]

    framework_path = nil
    on_macos do
      args += %W[
        --enable-dtrace
        --with-extra-ldflags=-headerpad_max_install_names
        --with-sysroot=#{MacOS.sdk_path}
      ]

      if Hardware::CPU.arm?
        # Path to dual-arch JavaNativeFoundation.framework from Xcode
        framework_path = File.expand_path(
          "../SharedFrameworks/ContentDeliveryServices.framework/Versions/Current/itms/java/Frameworks",
          MacOS::Xcode.prefix,
        )

        args += [
          "--openjdk-target=aarch64-apple-darwin",
          "--with-build-jdk=#{boot_jdk}",
          "--with-extra-cflags=-arch arm64",
          "--with-extra-cxxflags=-arch arm64",
          "--with-extra-ldflags=-arch arm64 -F#{framework_path}",
        ]
      end
    end

    chmod 0755, "configure"
    system "./configure", *args

    ENV["MAKEFLAGS"] = "JOBS=#{ENV.make_jobs}"
    system "make", "images"

    on_macos do
      jdk = Dir["build/*/images/jdk-bundle/*"].first
      libexec.install jdk => "openjdk.jdk"
      bin.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/bin/*"]
      include.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/include/*.h"]
      include.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/include/darwin/*.h"]
      man1.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/man/man1/*"]

      if Hardware::CPU.arm?
        dest = libexec/"openjdk.jdk/Contents/Home/lib/JavaNativeFoundation.framework"
        # Copy JavaNativeFoundation.framework from Xcode
        # https://gist.github.com/claui/ea4248aa64d6a1b06c6d6ed80bc2d2b8#gistcomment-3539574
        cp_r "#{framework_path}/JavaNativeFoundation.framework", dest, remove_destination: true

        # Replace Apple signature by ad-hoc one (otherwise relocation will break it)
        system "codesign", "-f", "-s", "-", dest/"Versions/A/JavaNativeFoundation"
      end
    end

    on_linux do
      libexec.install Dir["build/linux-x86_64-server-release/images/jdk/*"]
      bin.install_symlink Dir[libexec/"bin/*"]
      include.install_symlink Dir[libexec/"include/*.h"]
      include.install_symlink Dir[libexec/"include/linux/*.h"]
      man1.install_symlink Dir[libexec/"man/man1/*"]
    end
  end

  def caveats
    on_macos do
      s = <<~EOS
        For the system Java wrappers to find this JDK, symlink it with
          sudo ln -sfn #{opt_libexec}/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
      EOS

      if Hardware::CPU.arm?
        s += <<~EOS
          This is a beta version of openjdk for Apple Silicon
          (openjdk 17 preview).
        EOS
      end

      s
    end
  end

  test do
    (testpath/"HelloWorld.java").write <<~EOS
      class HelloWorld {
        public static void main(String args[]) {
          System.out.println("Hello, world!");
        }
      }
    EOS

    system bin/"javac", "HelloWorld.java"

    assert_match "Hello, world!", shell_output("#{bin}/java HelloWorld")
  end
end
