require 'semver'
require 'debugger'
#debugger

module Daitss
  VERSION_FORMAT = "v%M.%m.%p%s"
  VERSION = SemVer.find(File.dirname(__FILE__)).format VERSION_FORMAT
end

require 'daitss/archive'
require 'daitss/archive/submit'
require 'daitss/datetime'
require 'daitss/proc'

def DEPRECATED m
  raise m
end

def TODO m
  raise m
end
