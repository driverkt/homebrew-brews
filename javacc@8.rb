class JavaccAT8 < Formula
  desc "Parser generator for use with Java applications"
  homepage "https://javacc.github.io/javacc-8/"
  url "https://repo1.maven.org/maven2/org/javacc/core/8.1.0/core-8.1.0.jar"
  version "8.1.0"
  sha256 "8c516063b09f5aa5df023214ff9fca1786300fe49f5df848b968139eba547862"
  license "BSD-3-Clause"

  livecheck do
    url "https://repo1.maven.org/maven2/org/javacc/core/maven-metadata.xml"
    regex(/<release>\s*v?(\d+(?:\.\d+)+)\s*<\/release>/i)
  end

  keg_only :versioned_formula

  depends_on "openjdk"

  resource "generator-java" do
    url "https://repo1.maven.org/maven2/org/javacc/generator/java/8.1.0/java-8.1.0.jar"
    sha256 "ee718d6438325ce9b96fd415b9112125c4145fef3b5ddf6fcb7b4c900ae6da38"
  end

  def install
    # core-8.1.0.jar provides the javacc/jjtree/jjdoc entry points, but the
    # actual code generator for a target language is a separate jar that
    # core discovers at runtime via ServiceLoader<CodeGenerator>. Without
    # the generator jar on the classpath, generation fails with
    # "Could not load a CodeGenerator class handling: Java".
    libexec.install "core-8.1.0.jar"
    resource("generator-java").stage do
      libexec.install "java-8.1.0.jar"
    end

    classpath = "#{libexec}/core-8.1.0.jar:#{libexec}/java-8.1.0.jar"

    # All three tools live as default-package classes inside core-8.1.0.jar
    # whose class name matches the traditional command name, unchanged
    # from 7.x, so one loop covers javacc, jjtree, and jjdoc.
    %w[javacc jjtree jjdoc].each do |tool|
      (bin/tool).write <<~SH
        #!/bin/bash
        export JAVA_HOME="${JAVA_HOME:-#{formula_opt_prefix("openjdk")}}"
        exec "${JAVA_HOME}/bin/java" -classpath '#{classpath}' #{tool} "$@"
      SH
    end
  end

  test do
    (testpath/"Example.jj").write <<~JJ
      options {
        STATIC = false;
      }

      PARSER_BEGIN(Example)
      public class Example {}
      PARSER_END(Example)

      SKIP : { " " | "\\t" | "\\n" | "\\r" }

      TOKEN : { < WORD: (["a"-"z","A"-"Z"])+ > }

      void Input() :
      {}
      {
        (<WORD>)* <EOF>
      }
    JJ

    system bin/"javacc", "Example.jj"
    assert_path_exists testpath/"Example.java"

    system bin/"jjtree", "Example.jj"
    assert_path_exists testpath/"Example.jj.jj"

    system bin/"jjdoc", "Example.jj"
    assert_path_exists testpath/"Example.html"
  end
end
