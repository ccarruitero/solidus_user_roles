module SolidusUserRoles
  class Engine < Rails::Engine
    engine_name 'solidus_user_roles'
    config.autoload_paths += %W(#{config.root}/lib)

    config.generators do |g|
      g.test_framework :rspec
    end

    def self.load_custom_permissions
      Spree::RoleConfiguration.configure do |config|
        if ActiveRecord::Base.connection.tables.include?('spree_roles')
          Spree::Role.non_base_roles.each do |role|
            config.assign_permissions role.name, role.permission_sets_constantized
          end
        end
      end
    end


    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      unless Rails.env == 'test'
        SolidusUserRoles::Engine.load_custom_permissions
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
