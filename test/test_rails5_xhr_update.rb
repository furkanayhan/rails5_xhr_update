# frozen_string_literal: true

require 'minitest/autorun'
require 'rails5_xhr_update'

class XHRToRails5Test < MiniTest::Test
  def test_get
    source = convert <<~RB
      def get
        xhr :get, images_path
      end
    RB
    assert_includes(source, 'get images_path, xhr: true')
  end

  def test_get_with_empty_params
    source = convert <<~RB
      def get
        xhr :get, images_path, {}
      end
    RB
    assert_includes(source, 'get images_path, xhr: true')
  end

  def test_get_with_empty_params_empty_session
    source = convert <<~RB
      def get
        xhr :get, images_path, {}, {}
      end
    RB
    assert_includes(source, 'get images_path, xhr: true')
  end

  def test_get_with_empty_params_empty_session_empty_flash
    source = convert <<~RB
      def get
        xhr :get, images_path, {}, {}, {}
      end
    RB
    assert_includes(source, 'get images_path, xhr: true')
  end

  def test_get_with_empty_params_empty_session_flash
    source = convert <<~RB
      def get
        xhr :get, images_path, {}, {}, a: 1
      end
    RB
    assert_includes(source, 'get images_path, flash: { a: 1 }, xhr: true')
  end

  def test_get_with_empty_params_session
    source = convert <<~RB
      def get
        xhr :get, images_path, {}, a: 1
      end
    RB
    assert_includes(source, 'get images_path, session: { a: 1 }, xhr: true')
  end

  def test_get_with_nil_params_nil_session_nil_flash
    source = convert <<~RB
      def get
        xhr :get, images_path, nil, nil, nil
      end
    RB
    assert_includes(source, 'get images_path, xhr: true')
  end

  def test_get_with_params_session_flash
    source = convert <<~RB
      def get
        xhr :get, images_path, { id: 1 }, { user_ud: 2 }, success: 'logged in'
      end
    RB
    assert_includes(source, 'get images_path, flash: { success: "logged in" },'\
      ' params: { id: 1 }, session: { user_ud: 2 }, xhr: true')
  end

  def test_get_with_single_param
    source = convert <<~RB
      def get
        xhr :get, images_path, id: 1
      end
    RB
    assert_includes(source, 'get images_path, params: { id: 1 }, xhr: true')
  end

  private

  def convert(string)
    buffer = Parser::Source::Buffer.new('simple.rb')
    buffer.raw_source = string
    Rails5XHRUpdate::XHRToRails5.new.rewrite(
      buffer, Parser::CurrentRuby.new.parse(buffer)
    )
  end
end
