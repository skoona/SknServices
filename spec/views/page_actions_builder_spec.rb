##
#
#
#
#
##

describe PageActionsBuilder, "Builder of the Page Actions stack of menu dropdowns near top of selected pages." do
  let(:single) { [{
                    id: "test-action",
                    path: [:manage_content_profiles_profiles_path],
                    text: "Refresh",
                    icon: 'glyphicon-refresh',
                    html_options: {
                        data: {
                            samples: 'test data'
                        }
                    }
                  }]
  }

  let(:basic) { [{
                      id: "test-action",
                      path: [:manage_content_profiles_profiles_path],
                      text: "Refresh",
                      icon: 'glyphicon-refresh',
                      html_options: {
                          data: {
                              samples: 'test data'
                          }
                      }
                  },{
                       divider: true
                  },{
                       header: true
                  },{
                       path: [:manage_content_profiles_profiles_path],
                       text: "Refresh 2",
                  },{
                      path: [:manage_content_profiles_profiles_path],
                      text: "Refresh 3",
                  },{
                      path: [:manage_content_profiles_profiles_path],
                      text: "Refresh 4",
                  }]
  }

  let(:nested) { basic << basic }

  it "Can be initialized properly" do
    expect( PageActionsBuilder.new(single, view, true )).to be
  end

  context "Builds a single button menu from one entry. " do
    it "#generate produces a single button given only a single array element." do
      expect( PageActionsBuilder.new(single, view, true ).generate ).to be_a String
    end
    it "#to_s generates string output with normal specification." do
      str =  PageActionsBuilder.new(single, view, true ).to_s
      expect(str).to include '/a'
    end
    it "#to_s generates string output with maximum specification." do
      str =  PageActionsBuilder.new(single, view, true ).to_s
      expect(str).to include 'refresh'
    end
  end

  context "Builds basic level menu" do
    it "#to_s generates string output with normal specification." do
      str =  PageActionsBuilder.new(basic, view, true ).to_s
      expect(str).to include 'Refresh 4'
    end
  end

  context "Builds multi level menu" do
    it "#to_s generates string output with normal specification." do
      str =  PageActionsBuilder.new(nested, view, true ).to_s
      expect(str).to include 'Refresh 4'
    end
  end


end