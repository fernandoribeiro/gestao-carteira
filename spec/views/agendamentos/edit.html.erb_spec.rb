require 'spec_helper'

describe "agendamentos/edit" do
  before(:each) do
    @agendamento = assign(:agendamento, stub_model(Agendamento,
      :arquivo => "MyString",
      :unidade_id => 1,
      :status => 1
    ))
  end

  it "renders the edit agendamento form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", agendamento_path(@agendamento), "post" do
      assert_select "input#agendamento_arquivo[name=?]", "agendamento[arquivo]"
      assert_select "input#agendamento_unidade_id[name=?]", "agendamento[unidade_id]"
      assert_select "input#agendamento_status[name=?]", "agendamento[status]"
    end
  end
end
