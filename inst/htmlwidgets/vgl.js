HTMLWidgets.widget({

  name: 'vgl',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(params) {

        vegaEmbed(el, params.spec)

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
