module Minitest; end # :nodoc:

##
# Adds test hooks to verify the time it takes to run the setup, body,
# and teardown phases of each test. If the time of any phase goes over
# the maximum time, it fails the test. Use class variables to set the
# maximum thresholds and crank it down over time.

module Minitest::Speed
  VERSION = "1.0.1" # :nodoc:

  ##
  # Maximum setup time to pass a speed test. Default to 1.0 second.

  @@max_setup_time = 1.0

  ##
  # Maximum test time to pass a speed test. Default to 1.0 second.

  @@max_test_time = 1.0

  ##
  # Maximum teardown time to pass a speed test. Default to 1.0 second.

  @@max_teardown_time = 1.0

  def before_setup # :nodoc:
    super

    @setup_t0 = Time.now
  end

  def after_setup # :nodoc:
    delta = Time.now - @setup_t0

    @test_t0 = Time.now

    assert_operator delta, :<=, @@max_setup_time

    super
  end

  def before_teardown # :nodoc:
    super

    @teardown_t0 = Time.now

    delta = Time.now - @test_t0

    assert_operator delta, :<=, @@max_test_time
  end

  def after_teardown # :nodoc:
    delta = Time.now - @teardown_t0

    assert_operator delta, :<=, @@max_teardown_time

    super
  end
end
