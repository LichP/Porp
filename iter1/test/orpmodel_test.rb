prepare do
  Porp.set_options(:ns_deployment => 'unittest')
end

setup do
  Porp.purge_current_namespace!
end

test "rklass generates correct strings" do
  assert "orpmodel" == Porp::OrpModel.rklass
end

test "new_id increments appropriate uid key" do
  id = Porp::OrpModel.new_id
  assert 1.to_s == redis.get("#{Porp.ns}:orpmodel:uid")
end

test "new_id creates the 'created' key corresponding to the id" do
  id = Porp::OrpModel.new_id
  assert redis.exists("#{Porp.ns}:orpmodel:id:1:created")
end

test "objects with the same id are equal" do
  object1 = Porp::OrpModel.new(1)
  object2 = Porp::OrpModel.new(1)
  assert object1 == object2
end

test "exists? returns false when object data doesn't exist in redis" do
  assert !Porp::OrpModel.exists?(23)
end

test "property method creates accessor methods" do
  class PropertyTest < Porp::OrpModel
    property :testproperty
  end
  id = PropertyTest.new_id
  object = PropertyTest.new(id)
  object.testproperty = "Foo"
  assert "Foo" == redis.get("#{Porp.ns}:propertytest:id:1:testproperty")
  assert "Foo" == object.testproperty
end

test "find_by_id returns object with matching id when id exists" do
  id = Porp::OrpModel.new_id
  object = Porp::OrpModel.find_by_id(id)
  assert id == object.id
end

test "find_by_id returns nil when non-extant id passed" do
  assert nil == Porp::OrpModel.find_by_id(23)
end
