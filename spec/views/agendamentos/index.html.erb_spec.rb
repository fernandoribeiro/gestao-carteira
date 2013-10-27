require 'spec_helper'

describe "agendamentos/index" do
  before(:each) do
    assign(:agendamentos, [
      stub_model(Agendamento,
        :arquivo => "Arquivo",
        :unidade_id => 1,
        :status => 2
      ),
      stub_model(Agendamento,
        :arquivo => "Arquivo",
        :unidade_id => 1,
        :status => 2
      )
    ])
  end

  it "renders a list of agendamentos" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Arquivo".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
