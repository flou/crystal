require 'spec_helper'

describe 'Block inference' do
  it "infer type of empty block body" do
    assert_type(%q(
      def foo; yield; end

      foo do
      end
    )) { self.nil }
  end

  it "infer type of yield with empty block" do
    assert_type(%q(
      def foo
        yield
      end

      foo do
      end
    )) { self.nil }
  end

  it "infer type of block body" do
    input = parse %q(
      def foo; yield; end

      foo do
        x = 1
      end
    )
    mod = infer_type input
    input.last.block.body.target.type.should eq(mod.int)
  end

  it "infer type of block argument" do
    input = parse %q(
      def foo
        yield 1
      end

      foo do |x|
        1
      end
    )
    mod = infer_type input
    input.last.block.args[0].type.should eq(mod.int)
  end

  it "infer type of local variable" do
    input = parse %q(
      def foo
        yield 1
      end

      y = 'a'
      foo do |x|
        y = x
      end
      y
    )
    mod = infer_type input
    input.last.type.should eq(UnionType.new(mod.char, mod.int))
  end

  it "infer type of yield" do
    input = parse %q(
      def foo
        yield
      end

      foo do
        1
      end
    )
    mod = infer_type input
    input.last.type.should eq(mod.int)
  end

  it "infer type with union" do
    assert_type(%q(
      require "int"
      require "pointer"
      require "array"
      a = [1]
      a = [1.1]
      a.each { |x| x }
    )) { union_of(array_of(int), array_of(double)) }
  end

  it "break from block without value" do
    assert_type(%q(
      def foo; yield; end

      foo do
        break
      end
    )) { self.nil }
  end

  it "break without value has nil type" do
    assert_type(%q(
      def foo; yield; 1; end
      foo do
        break if false
      end
    )) { union_of(self.nil, int) }
  end

  it "infers type of block before call" do
    assert_type(%q(
      class Int
        def foo
          10.5
        end
      end

      class Foo(T)
        def initialize(x : T)
          @x = x
        end
      end

      def bar(&block : Int -> U)
        Foo(U).new(yield 1)
      end

      bar { |x| x.foo }
      )) { "Foo".generic(T: double).with_vars(x: double) }
  end

  it "infers type of block before call taking other args free vars into account" do
    assert_type(%q(
      class Foo(X)
        def initialize(x : X)
          @x = x
        end
      end

      def foo(x : U, &block: U -> T)
        Foo(T).new(yield x)
      end

      a = foo(1) do |x|
        10.5
      end
      )) { "Foo".generic(X: double).with_vars(x: double) }
  end
end
