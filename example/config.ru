require '../lib/spy_vs_spy'
require 'myapp'

use SOC::SpyVsSpy::Middleware

run MyApp
