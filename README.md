### Fork Description
This fork makes the library work using ruby 2 (2.1.5) and Yosemite. The instructions are based on the [original guide](https://github.com/plessl/wkpdf/wiki/How-to-install-on-MacOS-10.10-Yosemite) to installing under Yosemite.

1. Install Ruby through RVM with these options:   
`rvm install 2.1.5 --debug --reconfigure -C --enable-shared=yes`  

1. Start using the newly installed ruby: `rvm use 2.1.5` 

1. Build the gem from this repository using `gem build wkpdf.gemspec`, then install it using `gem install <gem-name>`.

1. Edit its bin `nano /usr/bin/wkpdf` so that in the first `#!` line it uses your newly installed ruby (do a `which ruby` and it should be something like `~/.rvm/rubies/ruby-2.1.5/bin/ruby`).

1. Download the latest RubyCocoa version:  
`wget http://sourceforge.net/projects/rubycocoa/files/RubyCocoa/1.2.0/RubyCocoa-1.2.0.tar.gz/download RubyCocoa-1.2.0.tar.gz -O RubyCocoa-1.2.0.tar.gz`

1. Uncompress into a folder and move into it: `tar xzf RubyCocoa-1.2.0.tar.gz && rm RubyCocoa-1.2.0.tar.gz && cd RubyCocoa-1.2.0`

1. Modify the install file `nano pre-install.rb`. (RubyCocoa 1.2.0 doesn't work with El Capitan, out of the box)
  - Add the following two lines at the top:
 ```
 Encoding.default_external = Encoding::UTF_8
 Encoding.default_internal = Encoding::UTF_8
 ```
 - Change the `lib_exists` method to
 ```
 def lib_exist?(path, sdkroot=@config['sdkroot'])
   File.exist?(path)
 end
 ```

1. Config the RubyCocoa installation: `ruby install.rb config --target-archs="x86_64"` (see [this gist](https://gist.github.com/thibaudgg/294465))

1. Setup & run the RubyCocoa installation:   
`ruby install.rb setup`  
`sudo ruby install.rb install`

1. That's it, run wkpdf's help to test it works:
`wkpdf --help`



-----

wkpdf
=====

Command line tool for rendering HTML to PDF using WebKit and RubyCocoa on Mac OS X

Although there are plenty of browsers available for Mac OS X, I could not find 
a command-line tool that allows for downloading a website and storing the 
rendered website as PDF. This was my motivation for creating wkpdf. The 
application uses Apple WebKit for rendering the HTML pages, thus the result 
should look similar to what you get when printing the webpage with Safari.

You find the latest information on how to install and use wkpdf on:

  [http://plessl.github.com/wkpdf](http://plessl.github.com/wkpdf)

For questions regarding wkpdf contact: wkpdf@plesslweb.ch

License
=======

Copyright (c) 2007-11 Christian Plessl

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
