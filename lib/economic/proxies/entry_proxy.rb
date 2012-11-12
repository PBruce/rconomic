require 'economic/proxies/entity_proxy'

module Economic
  class EntryProxy < EntityProxy
    def find_by_date_interval(from_date, to_date)
      response = session.request(entity_class.soap_action('FindByDateInterval')) do
        soap.body = {
          'fromDate' => from_date,
          'toDate'   => to_date
        }
      end

      build_array(response)
    end

    # Undocumented tip: if you only care about the min_number, pass in the maximum
    # possible value as max_number so you don't have to call `get_last_used_serial_number`:
    #
    #   max_number = 2**31 - 1  # Maximum int32.
    #
    def find_by_serial_number_interval(min_number, max_number)
      response = session.request(entity_class.soap_action('FindBySerialNumberInterval')) do
        soap.body = {
          'minNumber' => min_number,
          'maxNumber' => max_number
        }
      end

      build_array(response)
    end
    
    # Gets data for Entity from the API. Returns Hash with the response data
    def get_data_array(entities)
      entity_handles = entities.map {|handle| Entity::Handle.new(handle) unless handle.is_a?(Entity::Handle) }

      response = session.request(entity_class.soap_action(:get_data_array)) do
        # 'EntryHandle' => { 'SerialNumber' => handle.serial_number }
        # <EntryHandle>
        #                   <SerialNumber>int</SerialNumber>
        #                 </EntryHandle>
        
        soap.body = {
          'entityHandles' => entity_handles.map {|handle| 'EntryHandle' => { 'SerialNumber' => handle.serial_number } }
        }
      end
      
      build_array(response)
    end

    def get_last_used_serial_number
      response = session.request(entity_class.soap_action('GetLastUsedSerialNumber'))
      response.to_i
    end

    def find(serial_number)
      response = session.request(entity_class.soap_action('GetData')) do
        soap.body = {
          'entityHandle' => {
            'SerialNumber' => serial_number
           }
        }
      end

      build(response)
    end

    private

    def build_array(response)
      # The response[:entry_handle] format may be any of
      #   [{:serial_number=>"1"}, {:serial_number=>"2"}]  # Many results.
      #   {:serial_number=>"1"}                           # One result.
      #   nil                                             # No results.
      entry_handles = [ response[:entry_handle] ].flatten.compact

      entry_handles.map do |entry_handle|
        entry_handle[:serial_number].to_i
      end
    end
  end
end
