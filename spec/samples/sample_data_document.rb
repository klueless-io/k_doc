KDoc.model :sample_data do

  table :users do
    fields :user_name, :user, :email

    row :bad_ass  , 'Ken Va'    , 'ken@foliage.com.au'
    row :louise   , 'Louise'    , 'louise@gmail.com'
    row :alex     , 'Alexandro' , 'alex@gmail.com'
  end

  table :roles do
    fields :name

    row :owner
    row :staff
  end

  table :accounts do
    fields :type, :name

    row :cafe_owner, 'The Foliage Cafe'
    row :cafe_owner, 'The North Spoon'
    row :cafe_owner, 'Breadworks Cafe'
  end
    
  # __ = Lookup fields
  table :account_user_roles do
    fields :account__name, :user__user_name, :role__name

    row 'The Foliage Cafe'  , :bad_ass    , :owner
    row 'The Foliage Cafe'  , :louise     , :staff
    row 'The North Spoon'   , :alex       , :owner
    row 'Breadworks Cafe'   , :bad_ass    , :owner
  end

  table :groups, adk: :co_ops do 
    fields :name

    row :vietnamese
    row :thai
    row :korean
  end

  table :professional_service_types do 
    fields :name

    row :roasting
    row :mechanic
  end

  table :vendor_types do 
    fields :name, :examples

    row :milk
    row :tea
    row :coffee_beans
    row :dry_goods, [:lids, :paper_cups, :napkins, :cardboard_sleaves, :straws, :paper_towels]
    row :coffee_equipment, [:coffee_presses, :coffee_grinders, :espresso_machine, :water_filters]
    row :cafe_equipment, [:food_prep_tables, :food_storage_bins, :bottles, :pumps, :blenders, :ovens, :grills, :toasters, :ice_makers]
    row :produce
    row :butchers
    row :organic
    row :farmers
    row :baked_goods, [:muffins, :pastry]
    row :alcohol, [:wine, :spirits, :beer]
  end

  table :registries do 
    fields :name

    row :cafes
    row :coffee_providers
  end

  table :credit_application do 
    fields :tax_id, :delivery_address, :billing_address, :date_opened, :own_lease, :landlord_details, :bank_details
  end
end
