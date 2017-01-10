module LabelPrinter
  module PrintJob
    ##
    # A print job is an ActiveModel object
    # For a print job to be execute it needs to be valid.
    # For a print job to be valid it needs to meet the following criteria:
    # * The printer needs to exist.
    # * The label template needs to exist.
    # * It needs to have some labels.
    # If a print job is valid a DataInput object is created.
    class Base
      include ActiveModel::Model
      include ActiveModel::Serialization
      include SubclassChecker

      has_subclasses :LPD, :IPP, :TOF

      attr_accessor :printer_name, :label_template_id, :printer, :labels
      attr_reader :label_template, :data_input

      validates_presence_of :labels, :printer, :label_template
      validate :check_data_input, if: Proc.new { |print_job| print_job.data_input.present? }

      def initialize(attributes = {})
        super
        @printer ||= Printer.find_by_name(printer_name)
        @label_template = LabelTemplate.includes(:labels).find_by_id(label_template_id)
        @labels ||= {}
        if valid?
          @data_input = LabelPrinter::DataInput::Base.new(label_template, labels) 
        end
      end

      ##
      # A base object should never send a job to a printer,
      # because there won't be one!
      def execute
        valid?
      end

      ##
      # e.g. <# LabelPrinter::PrintJob::LPD >.type = LPD
      def type
        self.class.to_s.demodulize.capitalize
      end

      def id
        nil
      end

      def input
        @data_input.to_s
      end

      private

      def check_data_input
        unless data_input.valid?
          data_input.errors.each do |key, value|
            errors.add key, value
          end
        end
      end
      
      def check_printer
        unless printer.present?
          errors.add(:printer, 'does not exist')
        end
      end

      def check_label_template
        unless label_template.present?
          errors.add(:label_template, 'does not exist')
        end
      end

      def check_labels
        unless labels.any?
          errors.add(:labels, "can't be empty")
        end
      end
    end
  end
end
