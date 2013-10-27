require 'spec_helper'

describe "agendamentos/show" do
  before(:each) do
    @agendamento = assign(:agendamento, stub_model(Agendamento,
      :arquivo => "Arquivo",
      :unidade_id => 1,
      :status => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Arquivo/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
