module ForestLiana
  class HasManyDissociator
    def initialize(resource, association, params, forest_user)
      @resource = resource
      @association = association
      @params = params
      @with_deletion = @params[:delete].to_s == 'true'
      @data = params['data']
      @forest_user = forest_user
    end

    def perform
      @record = @resource.find(@params[:id])
      associated_records = @resource.find(@params[:id]).send(@association.name)

      remove_association = !@with_deletion || @association.macro == :has_and_belongs_to_many
      if @data.is_a?(Array)
        record_ids = @data.map { |record| record[:id] }
      elsif @data.dig('attributes').present?
        record_ids = ForestLiana::ResourcesGetter.get_ids_from_request(@params, @forest_user)
      else
        record_ids = Array.new
      end

      if !record_ids.nil? && record_ids.any?
        if remove_association
          record_ids.each do |id|
            associated_records.delete(SchemaUtils.association_ref(@association).find(id))
          end
        end

        if @with_deletion
        end
      end
    end
  end
end
