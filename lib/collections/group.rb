module Collections
  Group = Data.define(:record, :added_at, :owned_count, :specials_count, :unspecified_count, :eligible_count, :format_counts) do
    def show? = record.is_a?(Show)

    def regular_count = owned_count - specials_count
  end
end
