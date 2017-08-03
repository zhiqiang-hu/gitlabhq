FactoryGirl.define do
  factory :board do
    sequence(:name) { |n| "board#{n}" }
    project

    after(:create) do |board|
      board.lists.create(list_type: :closed)
    end
  end
end
