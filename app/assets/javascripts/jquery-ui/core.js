// jquery-ui-rails 8 ships jQuery UI 1.14, which removed jquery-ui/core.js.
// Active Scaffold 3.7 still require_asset's that path. Widgets pull in the
// replacement modules; this file only keeps the sprockets lookup working.
// Remove after upgrading to Active Scaffold >= 4.1.0.
