module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/                    then root_path
    when /the (login|logout) page/            then send(:"#{ $1 }_path")
    when /a secure page/                      then secure_path
    when /the batch search page/              then root_path
    when /the batch comparison page/          then batch_compare_path
    when /the show page for batch "([^\"]+)"/ then batch_path(:id => $1)
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
