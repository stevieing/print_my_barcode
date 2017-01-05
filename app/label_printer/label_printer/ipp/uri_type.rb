module LabelPrinter
  module IPP
    class UriType < OperationAttribute

      def initialize(value, value_tag = "0x45", name = "printer-uri")
        super(value_tag, name, value)
      end

    end
  end
end
