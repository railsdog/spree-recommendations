$j(function() {                                                                    
  var original_provider_type = $j('#provider-type').attr('value');
  $j('#settings-warning').hide();
  $j('#provider-type').change(function() { 
    if($j('#provider-type').attr('value') == original_provider_type){
      $j('#settings-warning').hide();
      $j('#preference-fields').show();
    } else {
      $j('#settings-warning').show();
      $j('#preference-fields').hide();
    }
  });
})
