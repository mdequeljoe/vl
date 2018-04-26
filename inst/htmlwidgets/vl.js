HTMLWidgets.widget({

  name: 'vl',

  type: 'output',

  factory: function(el, width, height) {
    
    return {
      
      renderValue: function(params) {
        vegaEmbed(el, params.spec, params.embed_opt);
      },

      resize: function(width, height) {}

    };
  }
});