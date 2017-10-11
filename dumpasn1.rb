require 'formula'

class Dumpasn1 < Formula
  homepage 'http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  url 'https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  version '20170404'
  sha256 '4b7c7d92c9593ee58c81019b2c3b7a7ee7450b733d38f196ce7560ee0e34d6b1'

  resource "cfg_file" do
    url "https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.cfg"
    sha256 "8b0c25bb3a4608b4678d25c56965e26e7780c73715032e447a506514a0815201"
  end

  def install
    resource("cfg_file").stage etc
    system "cc -o dumpasn1 dumpasn1.c"
    bin.install 'dumpasn1'
  end

  def test
    system "true"
  end
end
