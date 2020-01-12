# SvnRepoVerifier

## Overview

* Verify subversion repositories by ruby.

## Description

1. Read configs from the file. (`config.json`)
2. Verify each subversion repository.
3. Show the result.

## Requirement

* Ruby
* open3

~~~
$ bundle install
~~~

## Usage

~~~
$ ruby runner.rb
~~~

## Example

~~~
$ ruby runner.rb                 
Reading config...
["/path/to/subverion/repository"]
Checking repositories...
-----out-----
* Verifying metadata at revision 0 ...
* Verifying repository metadata ...
* Verifying metadata at revision 21 ...
* Verified revision 0.
* Verified revision 1.
* Verified revision 2.
...
* Verified revision 33.
-----error-----
-----status-----
pid 3673 exit 0
-Total: 1, Success: 1, Failure: 0
~~~

## Licence

* Copyright &copy; 2020 yusami
* Licensed under the [Apache License, Version 2.0][Apache]

[Apache]: http://www.apache.org/licenses/LICENSE-2.0


## Author

* [yusami](https://github.com/yusami)
