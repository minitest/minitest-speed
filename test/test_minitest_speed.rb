require "minitest/autorun"
require "minitest/speed"

module TestMinitest; end

class SpeedTest < Minitest::Test
  include Minitest::Speed

  @@max_setup_time    = 0.005
  @@max_test_time     = 0.015
  @@max_teardown_time = 0.025

  def self.go(&b)
    Class.new(SpeedTest, &b).new(:test_something).run
  end
end

class TestMinitest::TestSpeed < Minitest::Test
  def assert_slow(&b)
    refute_predicate SpeedTest.go(&b), :passed?
  end

  def assert_fast(&b)
    assert_predicate SpeedTest.go(&b), :passed?
  end

  def test_fast_setup
    assert_fast do
      def setup
        sleep 0.001
      end

      def test_something
        assert true
      end
    end
  end

  def test_slow_setup
    assert_slow do
      def setup
        sleep 0.01
      end

      def test_something
        assert true
      end
    end
  end

  def test_permit_slow_setup
    assert_fast do
      def setup
        permit_slow_setup
        sleep 0.01
      end

      def test_something
        assert true
      end
    end
  end

  def test_fast_test
    assert_fast do
      def test_something
        sleep 0.01
      end
    end
  end

  def test_slow_test
    assert_slow do
      def test_something
        sleep 0.02
      end
    end
  end

  def test_permit_slow_test
    assert_fast do
      def test_something
        permit_slow_test
        sleep 0.02
      end
    end
  end

  def test_fast_teardown
    assert_fast do
      def teardown
        sleep 0.01
      end

      def test_something
        assert true
      end
    end
  end

  def test_slow_teardown
    assert_slow do
      def teardown
        sleep 0.03
      end

      def test_something
        assert true
      end
    end
  end

  def test_permit_slow_teardown
    assert_fast do
      def teardown
        permit_slow_teardown
        sleep 0.03
      end

      def test_something
        assert true
      end
    end
  end

  def test_clock_time_method
    clock_time_method_was = Minitest::Speed.clock_time_method
    assert_fast do
      Minitest::Speed.clock_time_method = proc { 0 }
      def setup
        sleep(0.03)
      end

      def test_something
        assert true
      end
    end
  ensure
    Minitest::Speed.clock_time_method = clock_time_method_was
  end
end
