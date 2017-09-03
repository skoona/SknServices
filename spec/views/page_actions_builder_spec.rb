##
#
#
#
#
##

describe PageActionsBuilder, "Builder of the Page Actions stack of menu dropdowns near top of selected pages." do
  let(:single) { [{
                    id: "test-action",
                    path: [:in_depth_profiles_path],
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
                      path: [:in_depth_profiles_path],
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
                       header: true,
                       text: "Header Test"
                  },{
                       path: [:in_depth_profiles_path],
                       text: "Refresh 2",
                  },{
                      path: [:in_depth_profiles_path],
                      text: "Refresh 3",
                  },{
                      path: [:in_depth_profiles_path],
                      text: "Refresh 4",
                  }]
  }

  let(:full) {[
                { # Header Only
                    header: true,        # Exclusive: :id, :divider, & :text allowed
                    divider: true,       # optional
                    id: "test-action1",            # optional
                    text: "I am a Header"          # optional
                },
                { # Divider Only
                    divider: true,                 # Required
                    id: "test-action2"             # optional
                },
                { # Regular Dropdown Entry
                    id: "test-action3",
                    path: [:in_depth_profiles_path],
                    text: "Refresh",
                },
                { # Fully Dressed Entry
                    divider: true,       # appears after :li entry
                    id: "test-action4",
                    path: [:in_depth_profiles_path],
                    text: "Refresh",
                    icon: 'glyphicon-refresh',     # icons appear before text with seperating space
                    html_options: {                # applied to :link_to
                        class: 'something',
                        method: 'get',
                        data: {
                            target: '#',
                            package: ['someData']
                        }
                    }
                }]
  }


  let(:nested) {

    full << [{
         header: "Rspec Testing",
         id: "test-action",
         path: [:handle_content_profile_management_profiles_path],
         text: "Refresh",
         icon: 'glyphicon-refresh',
         html_options: {
             data: {
                 samples: 'test data'
             }
         }
     }]
  }

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
      expect(str).to include 'test data'
    end
  end


end