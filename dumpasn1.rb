require 'formula'

class Dumpasn1 < Formula
  homepage 'http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  url 'https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'
  version '20191022'
  sha256 'ba379c34d73ebf063081b760bc68b797091ec5e6b1c00052614a271119582e97'

  resource "cfg_file" do
    url "https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.cfg"
    sha256 "917f48e2e1f539c8cc9c1eb08ca4cfc9680a04ad194d47a16d89dd42551cc972"
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
