#!/usr/bin/env phantomjs
#
# PhantomJS drop-in replacement for wkhtmltoimage
#
# Copyright (c) 2013 Aaron Stone <aaron@serendipity.cx>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

helpBanner = 'PhantomJS drop-in for wkhtmltopdf and wkhtmltoimage by Aaron Stone'
switches = [
  ['-h', '--help',            'Display help']
  ['-H', '--extended-help',   'Display more extensive help, detailing less common command switches']
  ['-V', '--version',         'Output version information an exit']
  [      '--manpage',         'Output program man page']
  [      '--readme',          'Output program readme']

  ['-f', '--format [FORMAT]',                'Output file format (default is jpg)']
  ['-n', '--disable-javascript',             'Do not allow web pages to run javascript']
  ['-p', '--proxy [PROXY]',                  'Use a proxy']
  ['-0', '--disable-smart-width*',           'Use the specified width even if it is not large enough for the content']
  [      '--allow [PATH]',                   'Allow the file or files from the specified folder to be loaded (repeatable)']
  [      '--checkbox-checked-svg [PATH]',    'Use this SVG file when rendering checked checkboxes']
  [      '--checkbox-svg [PATH]',            'Use this SVG file when rendering unchecked checkboxes']
  [      '--cookie [NAME] [VALUE]',          'Set an additional cookie (repeatable)']
  [      '--cookie-jar [PATH]',              'Read and write cookies from and to the supplied cookie jar file']
  [      '--crop-h [INT]',                   'Set height for croping']
  [      '--crop-w [INT]',                   'Set width for croping']
  [      '--crop-x [INT]',                   'Set x coordinate for croping']
  [      '--crop-y [INT]',                   'Set y coordinate for croping']
  [      '--custom-header [NAME] [VALUE]',   'Set an additional HTTP header (repeatable)']
  [      '--custom-header-propagation',      'Add HTTP headers specified by --custom-header for each resource request.']
  [      '--no-custom-header-propagation',   'Do not add HTTP headers specified by --custom-header for each resource request.']
  [      '--debug-javascript',               'Show javascript debugging output']
  [      '--no-debug-javascript',            'Do not show javascript debugging output (default)']
  [      '--encoding [ENCODING]',            'Set the default text encoding, for input']
  [      '--height [HEIGHT]',                'Set screen height (default is calculated from page content) (default 0)']
  [      '--htmldoc',                        'Output program html help']
  [      '--images',                         'Do load or print images (default)']
  [      '--no-images',                      'Do not load or print images']
  [      '--enable-javascript',              'Do allow web pages to run javascript (default)']
  [      '--javascript-delay [MSEC]',        'Wait some milliseconds for javascript finish (default 200)']
  [      '--load-error-handling [HANDER]',   'Specify how to handle pages that fail to load: abort, ignore or skip (default abort)']
  [      '--disable-local-file-access',      'Do not allowed conversion of a local file to read in other local files, unless explecitily allowed with --allow']
  [      '--enable-local-file-access',       'Allowed conversion of a local file to read in other local files. (default)']
  [      '--minimum-font-size [INT]',        'Minimum font size']
  [      '--password [PASSWORD]',            'HTTP Authentication password']
  [      '--disable-plugins',                'Disable installed plugins (default)']
  [      '--enable-plugins',                 'Enable installed plugins (plugins will likely not work)']
  [      '--post [NAME] [VALUE]',            'Add an additional post field (repeatable)']
  [      '--post-file [VALUE] [PATH]',       'Post an additional file (repeatable)']
  [      '--quality [INT]',                  'Output image quality (between 0 and 100) (default 94)']
  [      '--radiobutton-checked-svg [PATH]', 'Use this SVG file when rendering checked radiobuttons']
  [      '--radiobutton-svg [PATH]',         'Use this SVG file when rendering unchecked radiobuttons']
  [      '--run-script [JS]',                'Run this additional javascript after the page is done loading (repeatable)']
  [      '--stop-slow-scripts',              'Stop slow running javascripts (default)']
  [      '--no-stop-slow-scripts',           'Do not Stop slow running javascripts (default)']
  [      '--transparent*',                   'Make the background transparent in pngs']
  [      '--user-style-sheet [URL]',         'Specify a user style sheet, to load with every page']
  [      '--username [USERNAME]',            'HTTP Authentication username']
  [      '--width [INT]',                    'Set screen width (default is 1024) (default 1024)']
  [      '--window-status [STATUS]',         'Wait until window.status is equal to this string before rendering page']
  [      '--zoom [FLOAT]',                   'Use this zoom factor (default 1)']
]

#optparse = require 'phantomjs://coffee-script/lib/coffee-script/optparse.js'
optparse = require './optparse'
parser  = new optparse.OptionParser switches, helpBanner

system = require 'system'
options = parser.parse system.args.slice 1

# Arguments
address = options.arguments[0]
output = options.arguments[1]
output = '/dev/stdout' if output is '-'

# Defaults
options.format  ||= 'jpg'
options.width   ||= 600
options.height  ||= 600
options.quality ||= 75
options.javascript_delay ||= 200

if options.help or system.args.length is 1
  console.log helpBanner
  console.log 'Usage: pjhtmltoimage [options] URL filename'
  phantom.exit 1

page = require('webpage').create()

page.viewportSize = { width: options.width, height: options.height}
# page.paperSize = { width: size[0], height: size[1], border: '0px' }
# page.paperSize = { format: system.args[3], orientation: 'portrait', border: '1cm' }

page.open address, (status) ->
  if status isnt 'success'
    console.log 'Unable to load the address!'
    phantom.exit()
  else
    window.setTimeout (-> (page.render output, { format: options.format, quality: options.quality }; phantom.exit())), options.javascript_delay
