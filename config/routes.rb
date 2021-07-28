Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.
	namespace 'api' do
		namespace 'v1' do
			get '/survivors/', to: 'survivors#index'
			get '/survivors/:id', to: 'survivors#show'
			post '/survivors/', to: 'survivors#create'
			put '/survivors/update/:id', to: 'survivors#update_location'
			put '/survivors/flag/:id', to: 'survivors#flag_survivor'

			get '/reports/infected', to: 'reports#infected'
			get '/reports/non-infected', to: 'reports#non_infected'
			get '/reports/average/:id', to: 'reports#average_amount_by_survivor'

			put '/trade/:id_1/:id_2', to: 'trades#trade'
		end
	end
end
