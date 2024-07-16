# It might be better for keeping up with the sha256sum to use the debian
# tarball available here:
# http://deb.debian.org/debian/pool/main/d/dumpasn1/dumpasn1_20210212.orig.tar.gz
#
# However, this is significantly out of date. I'm not aware of another
# packaged tarball, but maybe I'll come across one.

require "formula"

class Dumpasn1 < Formula
  homepage "http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c"
  url "https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c"
  version "20240319"
  sha256 "8ce8fdbf2e9b11d410b0ab4e44a6b3f89c27080113f051ec1054d230e050a0b8"

  resource("cfg_file") do
    url "https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.cfg"
    sha256 "7f74c3915a3a712c104b6d65c6204d005384813086260d8516f7b6e969fba9cf"
  end

  def install
    resource("cfg_file").stage(bin)
    system("cc -o dumpasn1 dumpasn1.c")
    bin.install("dumpasn1")
  end

  def test
    system("true")
  end
end
