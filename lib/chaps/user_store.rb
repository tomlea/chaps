require 'yaml'
class UserStore
  attr_reader :name
  
  def initialize(name)
    @name = name.dup.freeze
  end
  
  def friends=(friend_list)
    File.open("#{name}.yml", "w") do |f|
      f.write YAML.dump(friend_list)
    end
  end

  def friends
    if File.exist? "#{name}.yml"
      YAML.load File.read("#{name}.yml")
    else
      []
    end
  end
end
