defmodule Au4.Repo.Migrations.AlterApartmentToAddCharges do
  use Ecto.Migration

  def change do
    alter table :units do
      add :security, :string
      add :water_unit_price, :string
      add :parking, :string
      add :service_fee, :string
      add :internet, :string
      add :late_penalty, :string
      add :damages, :string
      add :repair, :string
      add :meter_reading, :string
      add :second_readig, :string
      add :key_access_card, :string
      add :utility_reconnection, :string
    end

  end
end
