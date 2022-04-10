class RemoveDesriptionFromCitationTickets < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_citation_tickets, :description, :string
  end
end
