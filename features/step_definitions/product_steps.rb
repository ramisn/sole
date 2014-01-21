Given /^I create a new product "(.+)"$/ do |product_name|
  step %{I am on the merchant store's new product page}
  store_taxon = Taxon.find_by_name("Nooka")
#  puts "*** found a taxon: _#{store_taxon}_ and a store _#{store_taxon.store unless store_taxon.nil?}_ for Nooka"
  step %{I fill in the following within "#new_product":}, table(%{
    | product[name] | #{product_name} |
    | product[description] | #{product_name} description |
    | product[price] | 1.99 |
  })
  step %{I select "Tops" from "taxon[product_type_id]"}
  step %{I select "Tees" from "taxon[product_category_id]"}
  step %{I select "NOOKA" from "taxon[brand_id]"}
  step %{I choose "department_0"}
  step %{I press "submit_button"}
end