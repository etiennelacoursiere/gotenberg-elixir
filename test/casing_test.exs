defmodule GotenbergElixir.CasingTest do
  use ExUnit.Case
  alias GotenbergElixir.Casing

  describe "camelize/1" do
    test "converts snake_case to camelCase" do
      assert Casing.camelize("foo_bar") == "fooBar"
      assert Casing.camelize("hello_world") == "helloWorld"
      assert Casing.camelize("some_long_variable_name") == "someLongVariableName"
    end

    test "converts kebab-case to camelCase" do
      assert Casing.camelize("foo-bar") == "fooBar"
      assert Casing.camelize("hello-world") == "helloWorld"
      assert Casing.camelize("some-long-variable-name") == "someLongVariableName"
    end

    test "handles single words" do
      assert Casing.camelize("foo") == "foo"
      assert Casing.camelize("hello") == "hello"
    end

    test "handles empty strings" do
      assert Casing.camelize("") == ""
    end

    test "handles strings with no separators" do
      assert Casing.camelize("foobar") == "foobar"
      assert Casing.camelize("FOOBAR") == "foobar"
    end

    test "handles mixed separators" do
      assert Casing.camelize("foo_bar-baz") == "fooBarBaz"
      assert Casing.camelize("hello-world_test") == "helloWorldTest"
    end

    test "handles consecutive separators" do
      assert Casing.camelize("foo__bar") == "fooBar"
      assert Casing.camelize("foo--bar") == "fooBar"
      assert Casing.camelize("foo_-_bar") == "fooBar"
    end

    test "handles atoms" do
      assert Casing.camelize(:foo_bar) == "fooBar"
      assert Casing.camelize(:hello_world) == "helloWorld"
    end

    test "handles numbers" do
      assert Casing.camelize(123) == "123"
    end
  end

  describe "camelize/2 with :upper option" do
    test "converts to PascalCase with uppercase first letter" do
      assert Casing.camelize("foo_bar", :upper) == "FooBar"
      assert Casing.camelize("hello_world", :upper) == "HelloWorld"
      assert Casing.camelize("some_long_variable_name", :upper) == "SomeLongVariableName"
    end

    test "handles kebab-case with :upper" do
      assert Casing.camelize("foo-bar", :upper) == "FooBar"
      assert Casing.camelize("hello-world", :upper) == "HelloWorld"
    end

    test "handles single words with :upper" do
      assert Casing.camelize("foo", :upper) == "Foo"
      assert Casing.camelize("hello", :upper) == "Hello"
    end

    test "handles empty strings with :upper" do
      assert Casing.camelize("", :upper) == ""
    end

    test "handles mixed separators with :upper" do
      assert Casing.camelize("foo_bar-baz", :upper) == "FooBarBaz"
      assert Casing.camelize("hello-world_test", :upper) == "HelloWorldTest"
    end
  end
end
