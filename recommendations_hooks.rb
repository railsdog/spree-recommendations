class RecommendationsHooks < Spree::ThemeSupport::HookListener
  
  insert_after :admin_configurations_sidebar_menu do
    %(
    <li<%= ' class="active"' if controller.controller_name == 'recommendation_providers' %>><%= link_to t("recommendation_providers"), admin_recommendation_providers_path %></li>
    )
  end

  insert_after :admin_configurations_menu do
    %(
    <tr>
      <td><%= link_to t("recommendation_providers"), admin_recommendation_providers_path %></td>
      <td><%= t("recommendation_providers_description") %></td>
    </tr>
    )
  end

  insert_after :admin_inside_head do
    "<%= javascript_include_tag 'admin/recommendation_providers' %>"
  end
  
end
