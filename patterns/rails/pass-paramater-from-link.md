# Pass an arbitrary parameter from an erb link to a controller.

> http://stackoverflow.com/questions/1898737/pass-parameter-by-link-to-ruby-on-rails

```erb
<%= link_to "text_to_show_in_url", action_controller_path(:gender => "male", :param2=> "something_else") %>
```