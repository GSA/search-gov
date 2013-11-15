ready = () ->
  $('#keen-io').each () ->
    new keentivate({
      projectId: "5277ef3dce5e430d5a000008",
      readKey: "ff01aaaf5bf0ed3fd540f99efe927d2cade14174af19d7d10732e13082f0c0141e6edb8fc69fdab42afd9554fc91a4ddda44b2478b2f38f7087b53bf08724e9f7535626ee1f21860cecb18bd2ad85a87d59c86c0ffdd0ba09f4a32d91e2f5165357339e42dbc8f050508d7d710fa5a0e" },
    {
      keenClass: "keentivate"
    });
$(document).ready ready
$(document).on 'page:load', ready
