require 'formula'

class Dumpasn1 < Formula
  homepage 'http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  url 'https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  version '20181212'
  sha256 'd42b7fb8457b9282ee341429baaaaf0ef7b2310cb28fcf2fc41914e07e8b1370'

  resource "cfg_file" do
    url "https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.cfg"
    sha256 "94245ed185e2bdb94b00ba031bb67ab83980748626f532ee4565df886468f196"
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
