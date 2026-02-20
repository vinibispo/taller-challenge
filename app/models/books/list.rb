module Books
  class List
    ALLOWED_SORT_COLUMNS = %w[created_at title status].freeze
    ALLOWED_DIRECTIONS = %w[asc desc].freeze

    private_constant :ALLOWED_SORT_COLUMNS, :ALLOWED_DIRECTIONS

    def execute(filters: {}, order: {})
      relation = Book.select(:id, :title, :status, :created_at)

      relation = apply_filters(relation, filters)

      relation = apply_sorting(relation, order)

      relation
    end

    private

    def apply_filters(relation, filters)
      return relation if filters.blank?

      relation = relation.where(status: filters[:status]) if filters[:status].present?

      if filters[:query].present?
        relation = relation.where("title LIKE ?", "%#{filters[:query]}%")
      end

      relation
    end

    def apply_sorting(relation, order_params)
      # Se order_params for vazio ou inválido, retorna ordem padrão
      return relation.order(created_at: :desc) if order_params.blank?

      sorting_criteria = {}

      # Iteramos sobre o hash de ordenação enviado pelo Controller
      order_params.each do |column, direction|
        next unless ALLOWED_SORT_COLUMNS.include?(column.to_s)
        dir = ALLOWED_DIRECTIONS.include?(direction&.downcase) ? direction : "asc"
        sorting_criteria[column] = dir
      end

      sorting_criteria.present? ? relation.order(sorting_criteria) : relation.order(created_at: :desc)
    end
  end
end
