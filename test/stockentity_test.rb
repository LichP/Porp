prepare do
  Porp.set_options(:ns_deployment => 'unittest')
end

setup do
  Porp.purge_current_namespace!
end

test "new stock entity should match input data" do
  desc = "Stock entity creation test"
  new_stke = Porp::StockEntity.new(desc)
  assert 1 == new_stke.id
  assert desc == new_stke.description
end
