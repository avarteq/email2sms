require "test/unit"
require File.dirname(__FILE__) + '/../../app/models/quoted_printable'

class EncodingTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_decode

    # puts unquote_quoted_printable_and_convert_to("=F6", "MacRoman", "ISO-8859-1" )
  end


 



#  # Fake test
#  def test_decode
#    unencoded = <<EOF
#EOF"=?ISO-8859-1?Q?Aihie4ca6a_=FCber_=F6st_=E4sth?=
#--001636c5a4903fc5d5046cb2a34a
#Content-Type: text/plain; charset=ISO-8859-1
#Content-Transfer-Encoding: quoted-printable
#
#=FCber =F6st =E
#EOF
#
#    puts QuotedPrintable.decode_qp(unencoded)
#  end
end