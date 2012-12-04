# <span class="ititle">Indexer</span> (v<span class="iversion">0.1.0</span>)

<b class="isummary">Enable Your Project's Metadata<b>

[![Build Status](https://secure.travis-ci.org/rubyworks/indexer.png)](http://travis-ci.org/rubyworks/indexer)

<p class="idescription">Indexer gives developers a unified data format for reusable project metadata.</p>

Indexer defines a *canonical*, detailed and strict, project <span class="icategory">metadata</span> specification.
The strictness of the specification makes the format simple enough for developers to use without an intermediate API.
Although Indexer also provides a convenience API for working with the specification and its data 
more loosely when suitable to the usecase. Indexer also specifies a stanadard location for canonized
metadata to be kept, in a `.index` file.

Indexer provides a tool to import metadata from external sources. Indexer can handle a variety of metadata
source formats, including YAML, HTML Micorformat and Ruby DSL scripts.


## Installation

Indexer is a Ruby application, so as long as you have Ruby installed, it is easy to install Indexer via RubyGems.

  $ gem install indexer


### Instructions

Indexer is capable of generating a canonical `.index` file from a variety of sources. Being so flexiable, exactly
how a developer descided to store a project's metadata is a largely a matter of taste. But in general there are
three overall approaches:

1. Specify the metadata using microformats in the project's README file.
2. Specify the metadata in one or more static files, typically a single YAML file.
3. Construct the metadata via a Ruby DSL, mixing static and/or external sources as one sees fit.

The first choice is, in many respects, the nicest because it does not require any additional files be added
to a project and it helps to ensure a good README file. On the downside, it requires some HTML be hand-coded
into a project's README file.

The second is a great option in the it is the easiest. One can quickly put together a YAML file of the 
supported metadata, and Indexer is very flexible in it's parsing of the YAML. SO it really is a quick and
user-friendly way to go. Typically this file will be called `METADATA` or `Metadata.yml`, but there is
no name requirement. In fact Indexer will let you split the metadata up over mutliple files, and even
use a whole directory of files, one per field, if that works best for you.

The last approach provides maximum flexablity. Using the Ruby DSL one can literally script the metadata,
which means it can come from anywhere at all. For example, you might want to pull the project's version
from the `lib/project/version.rb` file, i.e. bundler style. The DSL is as intutive and as flexible as 
using plain YAML, so it's nearly as easy to take this approach. By convention this file is called `Indexfile`,
but it too can be called anything one prefers.

On the Indexer wiki you can find detailed tutorials on a variety of setups, along with thier pros and cons.

One you have you metadata sources setup, its easy to build the canonical `.index` file using the `index` 
command line interface. For example, lets say we have customized our metadata via a DSL in `Indexfile`,
but we are also keeping the version information is a separate `VERSION` file. Then we can simple issue
the `index` command with the `-s/--source` option:

  $ index -s VERSION Indexfile 

And indexer will utilize both sources to construct the `.index` file.

Over time project metadata tends to evolve and change. To keep the canoncial `.index` file up to date simply
use the `index` command line tool with the the update option `-u/--update`.

  $ index -u

For more information on using Indexer, see the Wiki, API documentation, QED specification and the Manpages.


## Resources

<ul>
<li><a class="iresource" href="http://rubyworks.github.com/indexer" name="home">Homepage</a></li>
<li><a class="iresource" href="http://github.com/rubyworks/indexer" name="code">Source Code</a> (Github)</li>
<li><a class="iresource" href="http://rubydoc.info/gems/indexer/frames" name="docs">API Reference</a></li>
</ul>


## Requirements

<ul>
<li class="irequirement">
  <a class="name" href="http://nokogiri.org/">nokogiri</a> <span class="version">1.5+</span></span>
</li>
<li class="irequirement">
  <a class="name" href="https://github.com/vmg/redcarpet">redcarpet</a> <span class="version">2.2+</span></span>
</li>
<li class="irequirement">
  <a class="name" href="http://rubyworks.github.com/qed/">qed</a> <span class="version">2.9+</span> <span class="groups">(test)</span>
</li>
<li class="irequirement">
  <a class="name" href="http://rubyworks.github.com/ae/">ae</a> <span class="version"></span> <span class="groups">(test)</span>
</li>
</ul>

## Authors

<ul>
<li class="vcard iauthor">
  <div class="nickname">trans</div>
  <div><a class="email" href="mailto:transfire@gmail.com">transfire@gmail.com</a></div>
  <div><a class="url" href="http://trans.gihub.com/">http://trans.github.com/</a></div>
</li>
<li class="vcard iauthor">
  <div class="nickname">postmodern</div>
  <div><a class="url" href="http://postmodern.github.com/">http://postmodern.github.com/</a></div>
</li>
</ul>

## Copyrights

<ul>
<li class="icopyright">
  &copy; <span class="year">2012</span> <span class="holder">Rubyworks</span>
  <div class="license">
    <a href="http://www.spdx.org/licenses/BSD-2-Clause" rel="license">BSD-2-Clause License</a>
  </div>
</li>
<ul>

