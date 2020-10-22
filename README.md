# Appmap Auto Dependencies
A small ruby script that automatically adds the required dependencies to your ruby project so you can start appmapping right away.

## How to use the script
navigate to the directory you want to appmap and run
```sh
curl https://raw.githubusercontent.com/jaredKreppein/appmap_auto_dependencies/main/generate_dependencies.rb | ruby
```
prepare and run your tests with [appmap](https://github.com/applandinc/appmap-ruby)
```sh
bundle install
APPMAP=true bundle exec rake
```
## See it in action
Watch how to use this script along with the [appland-cli](https://github.com/applandinc/appland-cli) to seemlessly configure, map, and upload appmaps generated from [rails sample app 6th ed](https://github.com/mhartl/sample_app_6th_ed).

[![asciicast](https://asciinema.org/a/ZWhesCFC7cvtILawK3OsIZbg2.svg)](https://asciinema.org/a/ZWhesCFC7cvtILawK3OsIZbg2)

Want to see the full appmaps? Check it out the [full mapset](https://app.land/applications/219?mapset=1932).


## What it does
- generate an `appmap.yml` by finding core directories with ruby code inside
- add the appmap gem to `Gemfile`
- determine which test suite the repo uses (Rspec, Minitest, Cucumber) and adds the corresponding appmap dependencies
- determine if this is a rails app, and adds appmap railtie dependency<sup>1</sup>

<sup>1</sup>script currently only supports adding railtie dependencies if a `config/application.rb` exists. If you'd like to use this script with your rails app, follow the instructions from `appmap-ruby` in the link below

## Appmap Ruby
`appmap-ruby` is a Ruby Gem for recording
[AppMaps](https://github.com/applandinc/appmap) of your code.
"AppMap" is a data format which records code structure (modules, classes, and methods), code execution events
(function calls and returns), and code metadata (repo name, repo URL, commit
SHA, labels, etc). It's more granular than a performance profile, but it's less
granular than a full debug trace. It's designed to be optimal for understanding the design intent and behavior of code.

For more information on `appmap-ruby`, check out its [repo](https://github.com/applandinc/appmap-ruby).
