## HashLike#[]

    class X
      include DotRuby::HashLike
      attr_accessor :a
      def initialize(a)
        @a = a
      end
    end

    x = X.new(1)

    x[:a].should == 1

If a reader attribute doesn't exist it will raise
an error.

    expect NoMethodError do
      x[:q]
    end
