require 'formula'

class Zeromq < Formula
  homepage "http://www.zeromq.org/"
  url "http://download.zeromq.org/zeromq-4.0.5.tar.gz"
  sha1 "a664ec63661a848ef46114029156a0a6006feecd"

  bottle do
    cellar :any
    sha1 "36b69b2ddab7b16013290fdd5000ee9debaf74c1" => :mavericks
    sha1 "c81456068da0085d453770171050b51d2451dc2e" => :mountain_lion
    sha1 "4ec28e612016eafade64ace46d03c9ae7d42c594" => :lion
  end

  head do
    url "https://github.com/zeromq/libzmq.git"

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
  end


  option :universal
  option "with-pgm", "Build with PGM extension"

  depends_on "pkg-config" => :build
  depends_on "libpgm" if build.with? "pgm"
  depends_on "libsodium" => :optional

  def install
    ENV.universal_binary if build.universal?

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    if build.with? "pgm"
      # Use HB libpgm-5.2 because their internal 5.1 is b0rked.
      ENV['OpenPGM_CFLAGS'] = %x[pkg-config --cflags openpgm-5.2].chomp
      ENV['OpenPGM_LIBS'] = %x[pkg-config --libs openpgm-5.2].chomp
      args << "--with-system-pgm"
    end

    args << "--with-libsodium" if build.with? "libsodium"

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    To install the zmq gem on 10.6 with the system Ruby on a 64-bit machine,
    you may need to do:

        ARCHFLAGS="-arch x86_64" gem install zmq -- --with-zmq-dir=#{opt_prefix}
    EOS
  end
end
