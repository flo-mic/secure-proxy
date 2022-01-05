-- This module takes cae about the crowdsec initialization in case crowdsec is enabled
local cs = require "crowdsec.CrowdSec"
local ok, err = cs.init("/usr/local/lib/lua/crowdsec/crowdsec.conf")
if ok == nil then
  ngx.log(ngx.ERR, "[Crowdsec] " .. err)
  error()
end
ngx.log(ngx.NOTICE, "[Crowdsec] Initialisation done")