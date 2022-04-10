shared_examples 'a count statistic' do
  let(:date_range_type) { samples[:date_range_type] }
  let(:prev_data) { samples[:prev_data] > 0 ? samples[:prev_data] : 1 }
  let(:percentage) do
    (((samples[:current_data]-samples[:prev_data])*100)/prev_data.to_f)
  end
  let(:expectation) do
    {
      title: samples[:title],
      range_current_period: Statistics::Base::DATE_RANGE_LABELS[samples[:date_range_type]][:current],
      result: samples[:current_data].zero? ? 'NO DATA' : "#{samples[:current_data]} #{samples[:label]}",
      compare_with_previous_period: {
        raise: percentage > 0,
        percentage: "#{sprintf "%.2f", percentage.abs}%"
      },
      result_previous_period: "#{samples[:prev_data].zero? ? 'NO DATA' : samples[:prev_data]} from #{Statistics::Base::DATE_RANGE_LABELS[samples[:date_range_type]][:previous]}"
    }
  end

  it { is_expected.to eq expectation }
end
