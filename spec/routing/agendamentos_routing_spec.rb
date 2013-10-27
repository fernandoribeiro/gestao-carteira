require "spec_helper"

describe AgendamentosController do
  describe "routing" do

    it "routes to #index" do
      get("/agendamentos").should route_to("agendamentos#index")
    end

    it "routes to #new" do
      get("/agendamentos/new").should route_to("agendamentos#new")
    end

    it "routes to #show" do
      get("/agendamentos/1").should route_to("agendamentos#show", :id => "1")
    end

    it "routes to #edit" do
      get("/agendamentos/1/edit").should route_to("agendamentos#edit", :id => "1")
    end

    it "routes to #create" do
      post("/agendamentos").should route_to("agendamentos#create")
    end

    it "routes to #update" do
      put("/agendamentos/1").should route_to("agendamentos#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/agendamentos/1").should route_to("agendamentos#destroy", :id => "1")
    end

  end
end
