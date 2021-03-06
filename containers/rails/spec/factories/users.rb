FactoryBot.define do
  factory :user do
    password = Faker::Internet::password(8)
    email { Faker::Internet.unique.free_email }
    name  { Faker::Name.unique.last_name }
    password { password }
    password_confirmation { password }
    
    after(:create) do |user|
      create_list(:post, 4, user: user)
    end
  end
end
