## Version::Number.parse

The `parse` method ...

A String

    v = Indexer::Version::Number.parse('1.2.3')

    v.to_s.assert == '1.2.3'

An Array

    v = Indexer::Version::Number.parse([1,2,3])

    v.to_s.assert == '1.2.3'

Another Version::Number object

    v1 = Indexer::Version::Number.parse('2.5.6')
    v2 = Indexer::Version::Number.parse(v1)

    v2.to_s.assert == '2.5.6'

