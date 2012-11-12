require 'economic/entity'

module Economic
  class Account < Entity
    has_properties :name, :number, :balance, :block_direct_entries, :contra_account, :debit_credit, :department, :distribution_key, :is_accessible, :opening_account, :total_from, :type, :vat_account
    
    
    def handle
      Handle.new({number => @number})
    end
    
    
    def get_entries_by_number(min_number, max_number)
      response = session.request(entity_class.soap_action('GetEntriesByNumber')) do
        soap.body = {
          'accountHandle' => {
              'Number' => @number
            },
          'minNumber' => min_number,
          'maxNumber' => max_number
        }
      end

      build_array(response)
    end
    
    protected
    
    def build_soap_data
      data = ActiveSupport::OrderedHash.new

      data['Handle'] = handle.to_hash
      data['Name'] = handle.number
      data['Number'] = number
      
      return data
    end
  end
end