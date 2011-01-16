prepare do
  Porp.set_options(:ns_deployment => 'unittest')
end

setup do
  Porp.purge_current_namespace!
end

test "check namespace compile string" do
  assert "porp:mysite:unittest" == Porp.compile_ns_string
end

test "add a key to the namespace and list keys" do
  redis.set("#{Porp.ns}:testaddkey", 1)
  assert ["porp:mysite:unittest:testaddkey"] == Porp.ns_keys
end
