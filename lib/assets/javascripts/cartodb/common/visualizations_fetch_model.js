var cdb = require('cartodb.js');

/**
 * Model that encapsulates params for fetching data in a cdb.admin.Visualizations collection.
 */
module.exports = cdb.core.Model.extend({

  defaults: {
    content_type:   '',
    page:           1,
    q:              '',
    tag:            '',
    category:       '',
    shared:         'no',
    locked:         false,
    liked:          false,
    library:        false,
    order:          'updated_at'
  },

  isSearching: function() {
    return this.get('q') || this.get('tag');
  },

  isDatasets: function() {
    return this.get('content_type') === 'datasets';
  },

  isMaps: function() {
    return this.get('content_type') === 'maps';
  }
});
