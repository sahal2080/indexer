## Validator#initialize

### Bare Instance

A bare Validator object can be created by passing no arguments
to the initializer.

    data = Indexer::Validator.new

    data.revision.should == Indexer::REVISION

In addition, certain attributes will have default values.

    data.copyrights.should    == []
    data.authors.should       == []
    data.organizations.should == []
    data.requirements.should  == []
    data.conflicts.should     == []
    data.repositories.should  == []
    data.resources.should     == []

    data.paths.should         == { 'lib' => ['lib'] }

### Validator Argument

A Validator object can be created with initial values by passing a data
hash to the initializer.

    data = Indexer::Validator.new(:name=>'foo', :version=>'0.1.2')

    data.name.should == 'foo'
    data.version.should == '0.1.2'

Entries passed to the initializer are assigned via Validator's setters
and are validated upon assignment, so no invalid values can get into the
object's state, e.g.

    expect Indexer::ValidationError do
      Indexer::Validator.new(:name=>1)
    end

### Initial Validity 

The only way for a Validator object to be in an invalid state is
by the creation of an instance without providing a `name` and `version`.
Both name and version are required for a specification to be valid.

    data = Indexer::Validator.new

    data.refute.valid?

All other fields can be `nil` or the default values automatically assigned
as shown above.

