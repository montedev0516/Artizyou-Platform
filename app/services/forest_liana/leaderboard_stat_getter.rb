module ForestLiana
  class LeaderboardStatGetter < StatGetter

    end

    def perform
      includes = ForestLiana::QueryHelper.get_one_association_names_symbol(@scoped_child_model)

      result = @scoped_child_model
        .joins(includes)
        .where({ @scoped_parent_model.name.downcase.to_sym => @scoped_parent_model })
        .group(@group_by)
        .order(order)
        .limit(@limit)
        .send(@aggregate, @aggregate_field)
        .map { |key, value| { key: key, value: value } }

      @record = Model::Stat.new(value: result)
    end

    def get_scoped_model(model, forest_user, timezone)
      scope_filters = ForestLiana::ScopeManager.get_scope(model.name, forest_user)

      return model.unscoped if scope_filters.blank?

      FiltersParser.new(scope_filters, model, timezone, @params).apply_filters
    end

    def order
      order = 'DESC'

      # NOTICE: The generated alias for a count is "count_all", for a sum the
      #         alias looks like "sum_#{aggregate_field}"
      if @aggregate == 'sum'
        field = @aggregate_field.downcase
      else
        field = 'all'
      end
      "#{@aggregate}_#{field} #{order}"
    end
  end
end
