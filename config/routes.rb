Rails.application.routes.draw do

  root "pdf#index"
  
  match "/inert_id_bakestand_bakesheets" => "pdf#inert_id_bakestand_bakesheets",
        via: [:post]

  match "/inert_identification_bakesheet" => "pdf#inert_identification_bakesheet",
        via: [:post]
        
  match "/inert_bakestand_bakesheet" => "pdf#inert_bakestand_bakesheet",
        via: [:post]

  match "/inert_final_bakesheet" => "pdf#inert_final_bakesheet",
        via: [:post]

  match "/so" => "pdf#so",
        via: [:post, :get]

  match "/plating_certificate" => "pdf#plating_certificate",
        via: [:post, :get]

  match "/packing_slip" => "pdf#packing_slip",
        via: [:post, :get]

  match "/bill_of_lading" => "pdf#bill_of_lading",
        via: [:post, :get]

  match "/pay_stub" => "pdf#pay_stub",
        via: [:post, :get]

  match "/invoice" => "pdf#invoice",
        via: [:post, :get]

  match "/index" => "pdf#index",
        via: [:get]

end