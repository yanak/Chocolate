require 'chocolate/model/model_factory'
require 'chocolate/model/fwrs_model'

module Model

  class FwrsFactory < ModelFactory

    # @return [FwrsModel]
    def create
      return FwrsModel.new(@data_source)
    end

  end

end