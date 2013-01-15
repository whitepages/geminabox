require 'bundler/setup'
require 'geminabox'

Geminabox.data = File.expand_path(File.join(File.dirname(__FILE__), 'data'))
Geminabox.build_legacy = false
run Geminabox
