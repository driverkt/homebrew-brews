require 'formula'

class Dumpasn1 < Formula
  homepage 'http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  url 'https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  version '20230207'
  sha256 '8ce8fdbf2e9b11d410b0ab4e44a6b3f89c27080113f051ec1054d230e050a0b8'

  resource "cfg_file" do
    url "https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.cfg"
    sha256 "ed1eaafb0ad865b97738dfe0b0e5d602c76dc0cde4c0cee4cdcdd11c28f480e5"
  end

  def install
    resource("cfg_file").stage bin
    system "cc -o dumpasn1 dumpasn1.c"
    bin.install 'dumpasn1'
  end

  def test
    system "true"
  end
end
