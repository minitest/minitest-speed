module Minitest; end # :nodoc:

##
# Adds test hooks to verify the time it takes to run the setup, body,
# and teardown phases of each test. If the time of any phase goes over
# the maximum time, it fails the test. Use class variables to set the
# maximum thresholds and crank it down over time.

module Minitest::Speed
  VERSION = "1.0.2" # :nodoc:

  ##
  # Maximum setup time to pass a speed test. Default to 1.0 second.

  @@max_setup_time = 1.0

  ##
  # Maximum test time to pass a speed test. Default to 1.0 second.

  @@max_test_time = 1.0

  ##
  # Maximum teardown time to pass a speed test. Default to 1.0 second.

  @@max_teardown_time = 1.0

  ##
  # Default way of getting the current time.
  # @@clock_time_method = proc { Minitest.clock_time }

  mc = class << self; self; end

  ##
  # Default way of getting the current time.

  mc.attr_accessor :clock_time_method

  self.clock_time_method = -> { Minitest.clock_time }


  def before_setup # :nodoc:
    super

    @setup_t0 = Minitest::Speed.clock_time_method.call
  end

  def after_setup # :nodoc:
    delta = Minitest::Speed.clock_time_method.call - @setup_t0

    @test_t0 = Minitest::Speed.clock_time_method.call

    assert_operator delta, :<=, @@max_setup_time, "max_setup_time exceeded" unless @permit_slow_setup
    @permit_slow_setup = false

    super
  end

  def before_teardown # :nodoc:
    super

    @teardown_t0 = Minitest::Speed.clock_time_method.call

    delta = Minitest::Speed.clock_time_method.call - @test_t0

    assert_operator delta, :<=, @@max_test_time, "max_test_time exceeded" unless @permit_slow_test
    @permit_slow_test = false
  end

  def after_teardown # :nodoc:
    delta = Minitest::Speed.clock_time_method.call - @teardown_t0

    assert_operator delta, :<=, @@max_teardown_time, "max_teardown_time exceeded" unless @permit_slow_teardown
    @permit_slow_teardown = false

    super
  end

  ##
  # Disable setup speed assertion for the current setup.

  def permit_slow_setup
    @permit_slow_setup = true
  end

  ##
  # Disable test speed assertion for the current test.

  def permit_slow_test
    @permit_slow_test = true
  end

  ##
  # Disable teardown speed assertion for the current teardown.

  def permit_slow_teardown
    @permit_slow_teardown = true
  end
end
