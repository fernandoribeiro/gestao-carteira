require 'spec_helper'

describe "agendamentos/new" do
  before(:each) do
    assign(:agendamento, stub_model(Agendamento,
      :arquivo => "MyString",
      :unidade_id => 1,
      :status => 1
    ).as_new_record)
  end

  it "renders new agendamento form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", agendamentos_path, "post" do
      assert_select "input#agendamento_arquivo[name=?]", "agendamento[arquivo]"
      assert_select "input#agendamento_unidade_id[name=?]", "agendamento[unidade_id]"
      assert_select "input#agendamento_status[name=?]", "agendamento[status]"
    end
  end
end
