# AppMap Auto-configuration Script
A Ruby script that automatically adds the required dependencies to your Ruby project so you can start AppMapping right away.

## How to use the script
Make sure the `colorize ge,` is installed. If it is not, run
```sh
gem install colorize
```
Run this from the root directory of your project
```sh
curl https://raw.githubusercontent.com/jaredKreppein/appmap_auto_dependencies/main/generate_dependencies.rb | ruby
```
prepare and run your tests with [appmap](https://github.com/applandinc/appmap-ruby)
```sh
bundle install
APPMAP=true bundle exec rake
```
Your AppMap data files will be automatically created and stored in `/tmp/appmap`.

## What it does
- generate an `appmap.yml` by finding the core directories that house the app's code
- add the AppMap gem to `Gemfile`
- determine which test suite the repo uses (Rspec, Minitest, Cucumber) and adds the corresponding AppMap dependencies
- determine if this is a rails app, and adds the AppMap railtie dependency<sup>1</sup>

<sup>1</sup>script currently only supports adding railtie dependencies if a `config/application.rb` exists. If you'd like to use this script with your rails app, follow the instructions from `appmap-ruby` in the link at the bottom.

## See it in action
Watch how to use this script along with the [appland-cli](https://github.com/applandinc/appland-cli) to seemlessly configure, map, and upload appmaps generated from [rails sample app 6th ed](https://github.com/mhartl/sample_app_6th_ed).

[![asciicast](https://asciinema.org/a/ZWhesCFC7cvtILawK3OsIZbg2.svg)](https://asciinema.org/a/ZWhesCFC7cvtILawK3OsIZbg2)

Want to see the AppMaps for the Rails Sample App? Check out the [full mapset here](https://app.land/applications/219?mapset=1932).

## Appmap Ruby
`appmap-ruby` is a Ruby Gem for recording
[AppMaps](https://github.com/applandinc/appmap) of your code.
"AppMap" is a data format which records code structure (modules, classes, and methods), code execution events
(function calls and returns), and code metadata (repo name, repo URL, commit
SHA, labels, etc). It's more granular than a performance profile, but it's less
granular than a full debug trace. It's designed to be optimal for understanding the design intent and behavior of code.

For more information on `appmap-ruby`, check out its [README](https://github.com/applandinc/appmap-ruby).
