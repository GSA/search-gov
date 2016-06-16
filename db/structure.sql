CREATE TABLE `affiliate_feature_additions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliate_feature_additions_on_affiliate_id_and_feature_id` (`affiliate_id`,`feature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `affiliate_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) NOT NULL,
  `template_class` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `available` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliate_templates_on_affiliate_id_and_template_class` (`affiliate_id`,`template_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `affiliate_twitter_settings` (
  `affiliate_id` int(11) NOT NULL,
  `twitter_profile_id` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `show_lists` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `aff_id_tp_id` (`affiliate_id`,`twitter_profile_id`),
  KEY `index_affiliate_twitter_settings_on_twitter_profile_id` (`twitter_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `affiliates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `has_staged_content` tinyint(1) NOT NULL DEFAULT '0',
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_sayt_enabled` tinyint(1) DEFAULT '1',
  `display_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `external_css_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `favicon_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `css_properties` text COLLATE utf8_unicode_ci,
  `theme` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'en',
  `scope_ids` text COLLATE utf8_unicode_ci,
  `is_medline_govbox_enabled` tinyint(1) DEFAULT '0',
  `previous_fields_json` longtext COLLATE utf8_unicode_ci,
  `live_fields_json` longtext COLLATE utf8_unicode_ci,
  `staged_fields_json` longtext COLLATE utf8_unicode_ci,
  `uses_managed_header_footer` tinyint(1) DEFAULT NULL,
  `staged_uses_managed_header_footer` tinyint(1) DEFAULT NULL,
  `header_image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_image_file_size` int(11) DEFAULT NULL,
  `header_image_updated_at` datetime DEFAULT NULL,
  `fetch_concurrency` int(11) NOT NULL DEFAULT '1',
  `default_search_label` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `is_related_searches_enabled` tinyint(1) DEFAULT '1',
  `left_nav_label` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_web_property_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_background_image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_background_image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_background_image_file_size` int(11) DEFAULT NULL,
  `page_background_image_updated_at` datetime DEFAULT NULL,
  `is_photo_govbox_enabled` tinyint(1) DEFAULT '0',
  `mobile_logo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_logo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_logo_file_size` int(11) DEFAULT NULL,
  `mobile_logo_updated_at` datetime DEFAULT NULL,
  `jobs_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `agency_id` int(11) DEFAULT NULL,
  `raw_log_access_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `search_engine` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Bing',
  `is_rss_govbox_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `rss_govbox_label` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_video_govbox_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `dap_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `status_id` int(11) NOT NULL DEFAULT '2',
  `dublin_core_mappings` text COLLATE utf8_unicode_ci,
  `force_mobile_format` tinyint(1) NOT NULL DEFAULT '1',
  `gets_blended_results` tinyint(1) NOT NULL DEFAULT '0',
  `is_bing_image_search_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `is_federal_register_document_govbox_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `google_cx` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `google_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `api_access_key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `nutshell_id` int(11) DEFAULT NULL,
  `gets_commercial_results_on_blended_search` tinyint(1) NOT NULL DEFAULT '1',
  `gets_i14y_results` tinyint(1) NOT NULL DEFAULT '0',
  `header_tagline_logo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_tagline_logo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_tagline_logo_file_size` int(11) DEFAULT NULL,
  `header_tagline_logo_updated_at` datetime DEFAULT NULL,
  `search_consumer_search_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `domain_control_validation_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `i14y_date_stamp_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `active_template_id` int(11) DEFAULT NULL,
  `template_schema` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliates_on_name` (`name`),
  KEY `index_affiliates_on_active_template_id` (`active_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `affiliates_instagram_profiles` (
  `affiliate_id` int(11) NOT NULL,
  `instagram_profile_id` bigint(20) NOT NULL,
  UNIQUE KEY `index_affiliates_instagram_profiles` (`affiliate_id`,`instagram_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `affiliates_youtube_profiles` (
  `affiliate_id` int(11) DEFAULT NULL,
  `youtube_profile_id` int(11) DEFAULT NULL,
  UNIQUE KEY `affiliate_id_youtube_profile_id` (`affiliate_id`,`youtube_profile_id`),
  KEY `index_affiliates_youtube_profiles_on_youtube_profile_id` (`youtube_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `agencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `abbreviation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `federal_register_agency_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `agency_organization_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agency_id` int(11) DEFAULT NULL,
  `organization_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_agency_organization_codes_on_agency_id` (`agency_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `agency_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phrase` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `agency_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_agency_queries_on_phrase` (`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `title` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_alerts_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `boosted_content_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `boosted_content_id` int(11) NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_boosted_content_keywords_on_boosted_content_id` (`boosted_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `boosted_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `publish_start_on` date NOT NULL,
  `publish_end_on` date DEFAULT NULL,
  `match_keyword_values_only` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_boosted_contents_on_affiliate_id_and_title` (`affiliate_id`,`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `catalog_prefixes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `connections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `connected_affiliate_id` int(11) NOT NULL,
  `label` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `position` int(11) NOT NULL DEFAULT '100',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_connections_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `document_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sitelink_generator_names` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_document_collections_on_affiliate_id_and_name` (`affiliate_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `excluded_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_excluded_domains_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `excluded_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text COLLATE utf8_unicode_ci,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_excluded_urls_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `featured_collection_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `featured_collection_id` int(11) NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_featured_collection_keywords_on_featured_collection_id` (`featured_collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `featured_collection_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `featured_collection_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_featured_collection_links_on_featured_collection_id` (`featured_collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `featured_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `publish_start_on` date NOT NULL,
  `publish_end_on` date DEFAULT NULL,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `image_alt_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `match_keyword_values_only` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_featured_collections_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_features_on_internal_name` (`internal_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `federal_register_agencies` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `short_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `last_load_documents_requested_at` datetime DEFAULT NULL,
  `last_successful_load_documents_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `federal_register_agencies_federal_register_documents` (
  `federal_register_agency_id` int(11) NOT NULL,
  `federal_register_document_id` int(11) NOT NULL,
  UNIQUE KEY `index_federal_register_agencies_federal_register_documents` (`federal_register_agency_id`,`federal_register_document_id`),
  KEY `fra_frd_frdocid_idx` (`federal_register_document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `federal_register_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_number` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `abstract` text COLLATE utf8_unicode_ci,
  `html_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `document_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `start_page` int(11) NOT NULL,
  `end_page` int(11) NOT NULL,
  `page_length` int(11) NOT NULL,
  `publication_date` date NOT NULL,
  `comments_close_on` date DEFAULT NULL,
  `effective_on` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `docket_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `significant` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `flickr_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_flickr_profiles_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `help_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `help_page_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_help_links_on_request_path` (`request_path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `hints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hints_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `i14y_drawers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `handle` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `i14y_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `i14y_drawer_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_i14y_memberships_on_affiliate_id_and_i14y_drawer_id` (`affiliate_id`,`i14y_drawer_id`),
  KEY `index_i14y_memberships_on_i14y_drawer_id` (`i14y_drawer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `image_search_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_image_search_labels_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `indexed_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text COLLATE utf8_unicode_ci,
  `description` text COLLATE utf8_unicode_ci,
  `url` varchar(2000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `body` longtext COLLATE utf8_unicode_ci,
  `doctype` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_crawled_at` datetime DEFAULT NULL,
  `last_crawl_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `load_time` int(11) DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'rss',
  `published_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_indexed_documents_on_affiliate_id_and_id` (`affiliate_id`,`id`),
  KEY `by_aid_url` (`affiliate_id`,`url`(50))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `instagram_profiles` (
  `id` bigint(20) NOT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_google_supported` tinyint(1) NOT NULL DEFAULT '0',
  `is_bing_supported` tinyint(1) NOT NULL DEFAULT '0',
  `rtl` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `inferred_country_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_azure_supported` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `med_related_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `med_topic_id` int(11) NOT NULL,
  `related_medline_tid` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_related_topics_on_med_topic_id` (`med_topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `med_sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `med_topic_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_sites_on_med_topic_id` (`med_topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `med_synonyms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medline_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `topic_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_synonyms_on_medline_title` (`medline_title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `med_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medline_tid` int(11) DEFAULT NULL,
  `medline_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `medline_url` varchar(120) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` varchar(5) COLLATE utf8_unicode_ci DEFAULT 'en',
  `summary_html` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_topics_on_medline_tid` (`medline_tid`),
  KEY `index_med_topics_on_medline_title` (`medline_title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `affiliate_id` int(11) NOT NULL,
  `gets_daily_snapshot_email` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_memberships_on_affiliate_id_and_user_id` (`affiliate_id`,`user_id`),
  KEY `index_memberships_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `misspellings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wrong` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rite` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_misspellings_on_wrong` (`wrong`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `navigations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `navigable_id` int(11) NOT NULL,
  `navigable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `position` int(11) NOT NULL DEFAULT '100',
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_navigations_on_affiliate_id` (`affiliate_id`),
  KEY `index_navigations_on_navigable_id_and_navigable_type` (`navigable_id`,`navigable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `news_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `guid` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `published_at` datetime NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `rss_feed_url_id` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `contributor` text COLLATE utf8_unicode_ci,
  `subject` text COLLATE utf8_unicode_ci,
  `publisher` text COLLATE utf8_unicode_ci,
  `properties` text COLLATE utf8_unicode_ci,
  `body` longtext COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_news_items_on_rss_feed_url_id_and_link` (`rss_feed_url_id`,`link`),
  KEY `index_news_items_on_link` (`link`),
  KEY `index_news_items_on_rss_feed_url_id_and_guid` (`rss_feed_url_id`,`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `outbound_rate_limits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `limit` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `interval` varchar(10) COLLATE utf8_unicode_ci DEFAULT 'day',
  PRIMARY KEY (`id`),
  KEY `index_outbound_rate_limits_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `routed_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_routed_queries_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `routed_query_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `routed_query_id` int(11) DEFAULT NULL,
  `keyword` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_routed_query_keywords_on_routed_query_id_and_keyword` (`routed_query_id`,`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `rss_feed_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rss_feed_owner_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `last_crawled_at` datetime DEFAULT NULL,
  `last_crawl_status` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Pending',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `oasis_mrss_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rss_feed_urls_on_rss_feed_owner_type_and_url` (`rss_feed_owner_type`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `rss_feed_urls_rss_feeds` (
  `rss_feed_url_id` int(11) NOT NULL,
  `rss_feed_id` int(11) NOT NULL,
  UNIQUE KEY `index_rss_feed_urls_rss_feeds_on_rss_feed_id_and_rss_feed_url_id` (`rss_feed_id`,`rss_feed_url_id`),
  KEY `index_rss_feed_urls_rss_feeds_on_rss_feed_url_id` (`rss_feed_url_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `rss_feeds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_managed` tinyint(1) NOT NULL DEFAULT '0',
  `is_video` tinyint(1) NOT NULL DEFAULT '0',
  `owner_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `show_only_media_content` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_rss_feeds_on_affiliate_id` (`owner_id`),
  KEY `index_rss_feeds_on_owner_type_and_owner_id` (`owner_type`,`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sayt_filters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phrase` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `filter_only_exact_phrase` tinyint(1) NOT NULL DEFAULT '0',
  `is_regex` tinyint(1) NOT NULL DEFAULT '0',
  `accept` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sayt_filters_on_phrase` (`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sayt_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phrase` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `popularity` int(11) NOT NULL DEFAULT '1',
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `is_protected` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `is_whitelisted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sayt_suggestions_on_affiliate_id_and_phrase` (`affiliate_id`,`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `scoped_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `key` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_scoped_keys_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `search_modules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_search_modules_on_tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `site_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `site_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `domain` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_domains_on_affiliate_id_and_domain` (`affiliate_id`,`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `site_feed_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `rss_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `last_fetch_status` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Pending',
  `last_checked_at` datetime DEFAULT NULL,
  `quota` int(11) NOT NULL DEFAULT '1000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_feed_urls_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_statuses_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `suggestion_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_suggestion_blocks_on_query` (`query`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `superfresh_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text COLLATE utf8_unicode_ci,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_superfresh_urls_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `system_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tag_filters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `tag` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `exclude` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tag_filters_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `top_searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_top_searches_on_position_and_affiliate_id` (`position`,`affiliate_id`),
  KEY `index_top_searches_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tweet_id` bigint(20) unsigned NOT NULL,
  `tweet_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `twitter_profile_id` bigint(20) unsigned NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `urls` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tweets_on_tweet_id` (`tweet_id`),
  KEY `index_tweets_on_twitter_profile_id` (`twitter_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `twitter_lists` (
  `id` bigint(20) unsigned NOT NULL,
  `member_ids` mediumtext COLLATE utf8_unicode_ci,
  `last_status_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `statuses_updated_at` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  UNIQUE KEY `index_twitter_lists_on_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `twitter_lists_twitter_profiles` (
  `twitter_list_id` bigint(20) unsigned NOT NULL,
  `twitter_profile_id` int(11) NOT NULL,
  UNIQUE KEY `twitter_list_id_profile_id` (`twitter_list_id`,`twitter_profile_id`),
  KEY `index_twitter_lists_twitter_profiles_on_twitter_profile_id` (`twitter_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `twitter_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `twitter_id` bigint(20) unsigned NOT NULL,
  `screen_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `profile_image_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_twitter_profiles_on_twitter_id` (`twitter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `url_prefixes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_collection_id` int(11) NOT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_url_prefixes_on_document_collection_id_and_prefix` (`document_collection_id`,`prefix`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `perishable_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `persistence_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `is_affiliate_admin` tinyint(1) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_login_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `contact_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_affiliate` tinyint(1) NOT NULL DEFAULT '1',
  `organization_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `api_key` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `approval_status` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email_verification_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `welcome_email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `requires_manual_approval` tinyint(1) DEFAULT '0',
  `default_affiliate_id` int(11) DEFAULT NULL,
  `sees_filtered_totals` tinyint(1) NOT NULL DEFAULT '1',
  `nutshell_id` int(11) DEFAULT NULL,
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_api_key` (`api_key`),
  UNIQUE KEY `index_users_on_email_verification_token` (`email_verification_token`),
  KEY `index_users_on_perishable_token` (`perishable_token`),
  KEY `index_users_on_nutshell_id` (`nutshell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `watchers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `check_interval` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `throttle_period` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `conditions` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_window` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `query_blocklist` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `whitelisted_v1_api_handles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `handle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_whitelisted_v1_api_handles_on_handle` (`handle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `youtube_playlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `youtube_profile_id` int(11) DEFAULT NULL,
  `playlist_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `etag` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `news_item_ids` longtext COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_youtube_playlists_on_youtube_profile_id_and_playlist_id` (`youtube_profile_id`,`playlist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `youtube_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `channel_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `imported_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_youtube_profiles_on_channel_id` (`channel_id`),
  KEY `index_youtube_profiles_on_id_and_imported_at` (`id`,`imported_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20090818003200');

INSERT INTO schema_migrations (version) VALUES ('20090827135344');

INSERT INTO schema_migrations (version) VALUES ('20090830131735');

INSERT INTO schema_migrations (version) VALUES ('20090830133721');

INSERT INTO schema_migrations (version) VALUES ('20090830141034');

INSERT INTO schema_migrations (version) VALUES ('20090830142140');

INSERT INTO schema_migrations (version) VALUES ('20090830150517');

INSERT INTO schema_migrations (version) VALUES ('20090914192607');

INSERT INTO schema_migrations (version) VALUES ('20090914213039');

INSERT INTO schema_migrations (version) VALUES ('20090916135047');

INSERT INTO schema_migrations (version) VALUES ('20090924003837');

INSERT INTO schema_migrations (version) VALUES ('20090924003859');

INSERT INTO schema_migrations (version) VALUES ('20090924004347');

INSERT INTO schema_migrations (version) VALUES ('20090929171657');

INSERT INTO schema_migrations (version) VALUES ('20090930030530');

INSERT INTO schema_migrations (version) VALUES ('20091001185128');

INSERT INTO schema_migrations (version) VALUES ('20091015151736');

INSERT INTO schema_migrations (version) VALUES ('20091015181123');

INSERT INTO schema_migrations (version) VALUES ('20091029223615');

INSERT INTO schema_migrations (version) VALUES ('20091030151924');

INSERT INTO schema_migrations (version) VALUES ('20091106004909');

INSERT INTO schema_migrations (version) VALUES ('20091208191125');

INSERT INTO schema_migrations (version) VALUES ('20091210011500');

INSERT INTO schema_migrations (version) VALUES ('20091215192012');

INSERT INTO schema_migrations (version) VALUES ('20091218221303');

INSERT INTO schema_migrations (version) VALUES ('20091218235406');

INSERT INTO schema_migrations (version) VALUES ('20091219000213');

INSERT INTO schema_migrations (version) VALUES ('20091221202159');

INSERT INTO schema_migrations (version) VALUES ('20091221232552');

INSERT INTO schema_migrations (version) VALUES ('20100105214058');

INSERT INTO schema_migrations (version) VALUES ('20100120053149');

INSERT INTO schema_migrations (version) VALUES ('20100120201026');

INSERT INTO schema_migrations (version) VALUES ('20100121191230');

INSERT INTO schema_migrations (version) VALUES ('20100121191454');

INSERT INTO schema_migrations (version) VALUES ('20100122184251');

INSERT INTO schema_migrations (version) VALUES ('20100122190015');

INSERT INTO schema_migrations (version) VALUES ('20100122191430');

INSERT INTO schema_migrations (version) VALUES ('20100122220402');

INSERT INTO schema_migrations (version) VALUES ('20100124175356');

INSERT INTO schema_migrations (version) VALUES ('20100124180513');

INSERT INTO schema_migrations (version) VALUES ('20100126150542');

INSERT INTO schema_migrations (version) VALUES ('20100128125151');

INSERT INTO schema_migrations (version) VALUES ('20100129060051');

INSERT INTO schema_migrations (version) VALUES ('20100202025450');

INSERT INTO schema_migrations (version) VALUES ('20100202025510');

INSERT INTO schema_migrations (version) VALUES ('20100203232752');

INSERT INTO schema_migrations (version) VALUES ('20100302150635');

INSERT INTO schema_migrations (version) VALUES ('20100306210751');

INSERT INTO schema_migrations (version) VALUES ('20100306212231');

INSERT INTO schema_migrations (version) VALUES ('20100306213431');

INSERT INTO schema_migrations (version) VALUES ('20100310002858');

INSERT INTO schema_migrations (version) VALUES ('20100310003126');

INSERT INTO schema_migrations (version) VALUES ('20100310003534');

INSERT INTO schema_migrations (version) VALUES ('20100310163117');

INSERT INTO schema_migrations (version) VALUES ('20100313165633');

INSERT INTO schema_migrations (version) VALUES ('20100316202847');

INSERT INTO schema_migrations (version) VALUES ('20100319173135');

INSERT INTO schema_migrations (version) VALUES ('20100319181609');

INSERT INTO schema_migrations (version) VALUES ('20100321171719');

INSERT INTO schema_migrations (version) VALUES ('20100324024956');

INSERT INTO schema_migrations (version) VALUES ('20100325174330');

INSERT INTO schema_migrations (version) VALUES ('20100401021109');

INSERT INTO schema_migrations (version) VALUES ('20100401180826');

INSERT INTO schema_migrations (version) VALUES ('20100401210327');

INSERT INTO schema_migrations (version) VALUES ('20100402221817');

INSERT INTO schema_migrations (version) VALUES ('20100406005620');

INSERT INTO schema_migrations (version) VALUES ('20100407042525');

INSERT INTO schema_migrations (version) VALUES ('20100409141457');

INSERT INTO schema_migrations (version) VALUES ('20100411173938');

INSERT INTO schema_migrations (version) VALUES ('20100413141407');

INSERT INTO schema_migrations (version) VALUES ('20100413145803');

INSERT INTO schema_migrations (version) VALUES ('20100413154957');

INSERT INTO schema_migrations (version) VALUES ('20100415211606');

INSERT INTO schema_migrations (version) VALUES ('20100415211705');

INSERT INTO schema_migrations (version) VALUES ('20100419192955');

INSERT INTO schema_migrations (version) VALUES ('20100420213732');

INSERT INTO schema_migrations (version) VALUES ('20100423003915');

INSERT INTO schema_migrations (version) VALUES ('20100423004410');

INSERT INTO schema_migrations (version) VALUES ('20100423010137');

INSERT INTO schema_migrations (version) VALUES ('20100427215756');

INSERT INTO schema_migrations (version) VALUES ('20100429115931');

INSERT INTO schema_migrations (version) VALUES ('20100505031121');

INSERT INTO schema_migrations (version) VALUES ('20100526171400');

INSERT INTO schema_migrations (version) VALUES ('20100615221009');

INSERT INTO schema_migrations (version) VALUES ('20100615221025');

INSERT INTO schema_migrations (version) VALUES ('20100615221855');

INSERT INTO schema_migrations (version) VALUES ('20100615222319');

INSERT INTO schema_migrations (version) VALUES ('20100623143038');

INSERT INTO schema_migrations (version) VALUES ('20100623150837');

INSERT INTO schema_migrations (version) VALUES ('20100623151105');

INSERT INTO schema_migrations (version) VALUES ('20100623173419');

INSERT INTO schema_migrations (version) VALUES ('20100801234616');

INSERT INTO schema_migrations (version) VALUES ('20100803190405');

INSERT INTO schema_migrations (version) VALUES ('20100805171609');

INSERT INTO schema_migrations (version) VALUES ('20100813141129');

INSERT INTO schema_migrations (version) VALUES ('20100819135950');

INSERT INTO schema_migrations (version) VALUES ('20100819152301');

INSERT INTO schema_migrations (version) VALUES ('20100819182653');

INSERT INTO schema_migrations (version) VALUES ('20100824174959');

INSERT INTO schema_migrations (version) VALUES ('20100827144830');

INSERT INTO schema_migrations (version) VALUES ('20100908135939');

INSERT INTO schema_migrations (version) VALUES ('20100912060038');

INSERT INTO schema_migrations (version) VALUES ('20100913201908');

INSERT INTO schema_migrations (version) VALUES ('20100914213333');

INSERT INTO schema_migrations (version) VALUES ('20100914222343');

INSERT INTO schema_migrations (version) VALUES ('20100917164414');

INSERT INTO schema_migrations (version) VALUES ('20100923160526');

INSERT INTO schema_migrations (version) VALUES ('20100923161556');

INSERT INTO schema_migrations (version) VALUES ('20100927034711');

INSERT INTO schema_migrations (version) VALUES ('20100927131049');

INSERT INTO schema_migrations (version) VALUES ('20100928000201');

INSERT INTO schema_migrations (version) VALUES ('20100928000646');

INSERT INTO schema_migrations (version) VALUES ('20100929205439');

INSERT INTO schema_migrations (version) VALUES ('20100929214757');

INSERT INTO schema_migrations (version) VALUES ('20100930182206');

INSERT INTO schema_migrations (version) VALUES ('20101003191357');

INSERT INTO schema_migrations (version) VALUES ('20101007221355');

INSERT INTO schema_migrations (version) VALUES ('20101007232915');

INSERT INTO schema_migrations (version) VALUES ('20101012191557');

INSERT INTO schema_migrations (version) VALUES ('20101013200500');

INSERT INTO schema_migrations (version) VALUES ('20101013203634');

INSERT INTO schema_migrations (version) VALUES ('20101019134728');

INSERT INTO schema_migrations (version) VALUES ('20101022163543');

INSERT INTO schema_migrations (version) VALUES ('20101028220805');

INSERT INTO schema_migrations (version) VALUES ('20101108142930');

INSERT INTO schema_migrations (version) VALUES ('20101108223719');

INSERT INTO schema_migrations (version) VALUES ('20101108223827');

INSERT INTO schema_migrations (version) VALUES ('20101110214355');

INSERT INTO schema_migrations (version) VALUES ('20101110234928');

INSERT INTO schema_migrations (version) VALUES ('20101117185756');

INSERT INTO schema_migrations (version) VALUES ('20101118143644');

INSERT INTO schema_migrations (version) VALUES ('20101118161945');

INSERT INTO schema_migrations (version) VALUES ('20101123220917');

INSERT INTO schema_migrations (version) VALUES ('20101210014112');

INSERT INTO schema_migrations (version) VALUES ('20101210021715');

INSERT INTO schema_migrations (version) VALUES ('20101222015949');

INSERT INTO schema_migrations (version) VALUES ('20110103071549');

INSERT INTO schema_migrations (version) VALUES ('20110106001640');

INSERT INTO schema_migrations (version) VALUES ('20110106150740');

INSERT INTO schema_migrations (version) VALUES ('20110111175041');

INSERT INTO schema_migrations (version) VALUES ('20110113235733');

INSERT INTO schema_migrations (version) VALUES ('20110114010639');

INSERT INTO schema_migrations (version) VALUES ('20110124181045');

INSERT INTO schema_migrations (version) VALUES ('20110125175354');

INSERT INTO schema_migrations (version) VALUES ('20110125192541');

INSERT INTO schema_migrations (version) VALUES ('20110125194002');

INSERT INTO schema_migrations (version) VALUES ('20110127195543');

INSERT INTO schema_migrations (version) VALUES ('20110128183710');

INSERT INTO schema_migrations (version) VALUES ('20110203181742');

INSERT INTO schema_migrations (version) VALUES ('20110204160803');

INSERT INTO schema_migrations (version) VALUES ('20110204195947');

INSERT INTO schema_migrations (version) VALUES ('20110204200027');

INSERT INTO schema_migrations (version) VALUES ('20110208115622');

INSERT INTO schema_migrations (version) VALUES ('20110211164031');

INSERT INTO schema_migrations (version) VALUES ('20110211210757');

INSERT INTO schema_migrations (version) VALUES ('20110216004225');

INSERT INTO schema_migrations (version) VALUES ('20110225142438');

INSERT INTO schema_migrations (version) VALUES ('20110225185031');

INSERT INTO schema_migrations (version) VALUES ('20110301163608');

INSERT INTO schema_migrations (version) VALUES ('20110301163712');

INSERT INTO schema_migrations (version) VALUES ('20110302225332');

INSERT INTO schema_migrations (version) VALUES ('20110303005150');

INSERT INTO schema_migrations (version) VALUES ('20110303155705');

INSERT INTO schema_migrations (version) VALUES ('20110304145634');

INSERT INTO schema_migrations (version) VALUES ('20110316144126');

INSERT INTO schema_migrations (version) VALUES ('20110317221114');

INSERT INTO schema_migrations (version) VALUES ('20110318115823');

INSERT INTO schema_migrations (version) VALUES ('20110328225035');

INSERT INTO schema_migrations (version) VALUES ('20110328231258');

INSERT INTO schema_migrations (version) VALUES ('20110328233426');

INSERT INTO schema_migrations (version) VALUES ('20110328234107');

INSERT INTO schema_migrations (version) VALUES ('20110329044945');

INSERT INTO schema_migrations (version) VALUES ('20110329045844');

INSERT INTO schema_migrations (version) VALUES ('20110329050058');

INSERT INTO schema_migrations (version) VALUES ('20110329050302');

INSERT INTO schema_migrations (version) VALUES ('20110330212048');

INSERT INTO schema_migrations (version) VALUES ('20110331212739');

INSERT INTO schema_migrations (version) VALUES ('20110331213758');

INSERT INTO schema_migrations (version) VALUES ('20110401215815');

INSERT INTO schema_migrations (version) VALUES ('20110404130848');

INSERT INTO schema_migrations (version) VALUES ('20110407141548');

INSERT INTO schema_migrations (version) VALUES ('20110411123231');

INSERT INTO schema_migrations (version) VALUES ('20110419195340');

INSERT INTO schema_migrations (version) VALUES ('20110420223513');

INSERT INTO schema_migrations (version) VALUES ('20110423194742');

INSERT INTO schema_migrations (version) VALUES ('20110425041201');

INSERT INTO schema_migrations (version) VALUES ('20110425182649');

INSERT INTO schema_migrations (version) VALUES ('20110512160939');

INSERT INTO schema_migrations (version) VALUES ('20110513001443');

INSERT INTO schema_migrations (version) VALUES ('20110602132347');

INSERT INTO schema_migrations (version) VALUES ('20110602164037');

INSERT INTO schema_migrations (version) VALUES ('20110603161852');

INSERT INTO schema_migrations (version) VALUES ('20110603204350');

INSERT INTO schema_migrations (version) VALUES ('20110607192052');

INSERT INTO schema_migrations (version) VALUES ('20110609125539');

INSERT INTO schema_migrations (version) VALUES ('20110610224518');

INSERT INTO schema_migrations (version) VALUES ('20110610225954');

INSERT INTO schema_migrations (version) VALUES ('20110621205934');

INSERT INTO schema_migrations (version) VALUES ('20110706013212');

INSERT INTO schema_migrations (version) VALUES ('20110715175055');

INSERT INTO schema_migrations (version) VALUES ('20110715175134');

INSERT INTO schema_migrations (version) VALUES ('20110715175201');

INSERT INTO schema_migrations (version) VALUES ('20110722233615');

INSERT INTO schema_migrations (version) VALUES ('20110727180259');

INSERT INTO schema_migrations (version) VALUES ('20110801215424');

INSERT INTO schema_migrations (version) VALUES ('20110801220700');

INSERT INTO schema_migrations (version) VALUES ('20110802190415');

INSERT INTO schema_migrations (version) VALUES ('20110802190508');

INSERT INTO schema_migrations (version) VALUES ('20110811165030');

INSERT INTO schema_migrations (version) VALUES ('20110813150408');

INSERT INTO schema_migrations (version) VALUES ('20110813150925');

INSERT INTO schema_migrations (version) VALUES ('20110815164006');

INSERT INTO schema_migrations (version) VALUES ('20110815202652');

INSERT INTO schema_migrations (version) VALUES ('20110819063140');

INSERT INTO schema_migrations (version) VALUES ('20110820030917');

INSERT INTO schema_migrations (version) VALUES ('20110822152349');

INSERT INTO schema_migrations (version) VALUES ('20110822160220');

INSERT INTO schema_migrations (version) VALUES ('20110823044733');

INSERT INTO schema_migrations (version) VALUES ('20110829215806');

INSERT INTO schema_migrations (version) VALUES ('20110831215243');

INSERT INTO schema_migrations (version) VALUES ('20110831220908');

INSERT INTO schema_migrations (version) VALUES ('20110901045031');

INSERT INTO schema_migrations (version) VALUES ('20110901045151');

INSERT INTO schema_migrations (version) VALUES ('20110912160352');

INSERT INTO schema_migrations (version) VALUES ('20110912222019');

INSERT INTO schema_migrations (version) VALUES ('20110913050747');

INSERT INTO schema_migrations (version) VALUES ('20110914143122');

INSERT INTO schema_migrations (version) VALUES ('20110914204915');

INSERT INTO schema_migrations (version) VALUES ('20110915172744');

INSERT INTO schema_migrations (version) VALUES ('20110916015126');

INSERT INTO schema_migrations (version) VALUES ('20110916141952');

INSERT INTO schema_migrations (version) VALUES ('20110926194832');

INSERT INTO schema_migrations (version) VALUES ('20110926225428');

INSERT INTO schema_migrations (version) VALUES ('20110926230137');

INSERT INTO schema_migrations (version) VALUES ('20110926233554');

INSERT INTO schema_migrations (version) VALUES ('20110928173111');

INSERT INTO schema_migrations (version) VALUES ('20110930175157');

INSERT INTO schema_migrations (version) VALUES ('20111004150008');

INSERT INTO schema_migrations (version) VALUES ('20111004150929');

INSERT INTO schema_migrations (version) VALUES ('20111005135312');

INSERT INTO schema_migrations (version) VALUES ('20111005140949');

INSERT INTO schema_migrations (version) VALUES ('20111007140523');

INSERT INTO schema_migrations (version) VALUES ('20111013220704');

INSERT INTO schema_migrations (version) VALUES ('20111013230036');

INSERT INTO schema_migrations (version) VALUES ('20111014145612');

INSERT INTO schema_migrations (version) VALUES ('20111015010710');

INSERT INTO schema_migrations (version) VALUES ('20111017155756');

INSERT INTO schema_migrations (version) VALUES ('20111017175410');

INSERT INTO schema_migrations (version) VALUES ('20111019184243');

INSERT INTO schema_migrations (version) VALUES ('20111025135656');

INSERT INTO schema_migrations (version) VALUES ('20111028041409');

INSERT INTO schema_migrations (version) VALUES ('20111028181817');

INSERT INTO schema_migrations (version) VALUES ('20111031142229');

INSERT INTO schema_migrations (version) VALUES ('20111103131805');

INSERT INTO schema_migrations (version) VALUES ('20111107164015');

INSERT INTO schema_migrations (version) VALUES ('20111109175611');

INSERT INTO schema_migrations (version) VALUES ('20111109202025');

INSERT INTO schema_migrations (version) VALUES ('20111115140559');

INSERT INTO schema_migrations (version) VALUES ('20111116000953');

INSERT INTO schema_migrations (version) VALUES ('20111116155052');

INSERT INTO schema_migrations (version) VALUES ('20111121160027');

INSERT INTO schema_migrations (version) VALUES ('20111121201602');

INSERT INTO schema_migrations (version) VALUES ('20111123194534');

INSERT INTO schema_migrations (version) VALUES ('20111123212028');

INSERT INTO schema_migrations (version) VALUES ('20111129163521');

INSERT INTO schema_migrations (version) VALUES ('20111129192643');

INSERT INTO schema_migrations (version) VALUES ('20111130175117');

INSERT INTO schema_migrations (version) VALUES ('20111205205515');

INSERT INTO schema_migrations (version) VALUES ('20111214221958');

INSERT INTO schema_migrations (version) VALUES ('20111214230059');

INSERT INTO schema_migrations (version) VALUES ('20111216181022');

INSERT INTO schema_migrations (version) VALUES ('20111216181023');

INSERT INTO schema_migrations (version) VALUES ('20111220072415');

INSERT INTO schema_migrations (version) VALUES ('20111220080239');

INSERT INTO schema_migrations (version) VALUES ('20111221214128');

INSERT INTO schema_migrations (version) VALUES ('20111223182349');

INSERT INTO schema_migrations (version) VALUES ('20111223185253');

INSERT INTO schema_migrations (version) VALUES ('20111227193551');

INSERT INTO schema_migrations (version) VALUES ('20111231170242');

INSERT INTO schema_migrations (version) VALUES ('20111231231620');

INSERT INTO schema_migrations (version) VALUES ('20120103164925');

INSERT INTO schema_migrations (version) VALUES ('20120105184148');

INSERT INTO schema_migrations (version) VALUES ('20120106033207');

INSERT INTO schema_migrations (version) VALUES ('20120106034114');

INSERT INTO schema_migrations (version) VALUES ('20120108063217');

INSERT INTO schema_migrations (version) VALUES ('20120108063305');

INSERT INTO schema_migrations (version) VALUES ('20120109155826');

INSERT INTO schema_migrations (version) VALUES ('20120110175025');

INSERT INTO schema_migrations (version) VALUES ('20120117142157');

INSERT INTO schema_migrations (version) VALUES ('20120117143759');

INSERT INTO schema_migrations (version) VALUES ('20120119173016');

INSERT INTO schema_migrations (version) VALUES ('20120123150805');

INSERT INTO schema_migrations (version) VALUES ('20120124175734');

INSERT INTO schema_migrations (version) VALUES ('20120131070052');

INSERT INTO schema_migrations (version) VALUES ('20120202223824');

INSERT INTO schema_migrations (version) VALUES ('20120206042507');

INSERT INTO schema_migrations (version) VALUES ('20120207032127');

INSERT INTO schema_migrations (version) VALUES ('20120207192617');

INSERT INTO schema_migrations (version) VALUES ('20120209184735');

INSERT INTO schema_migrations (version) VALUES ('20120210000606');

INSERT INTO schema_migrations (version) VALUES ('20120210002248');

INSERT INTO schema_migrations (version) VALUES ('20120214020545');

INSERT INTO schema_migrations (version) VALUES ('20120217154658');

INSERT INTO schema_migrations (version) VALUES ('20120217154818');

INSERT INTO schema_migrations (version) VALUES ('20120222190534');

INSERT INTO schema_migrations (version) VALUES ('20120224042646');

INSERT INTO schema_migrations (version) VALUES ('20120224194438');

INSERT INTO schema_migrations (version) VALUES ('20120302183638');

INSERT INTO schema_migrations (version) VALUES ('20120305164845');

INSERT INTO schema_migrations (version) VALUES ('20120306153732');

INSERT INTO schema_migrations (version) VALUES ('20120306160329');

INSERT INTO schema_migrations (version) VALUES ('20120306163134');

INSERT INTO schema_migrations (version) VALUES ('20120306184550');

INSERT INTO schema_migrations (version) VALUES ('20120307160707');

INSERT INTO schema_migrations (version) VALUES ('20120309023914');

INSERT INTO schema_migrations (version) VALUES ('20120309023945');

INSERT INTO schema_migrations (version) VALUES ('20120314001622');

INSERT INTO schema_migrations (version) VALUES ('20120315135638');

INSERT INTO schema_migrations (version) VALUES ('20120317001910');

INSERT INTO schema_migrations (version) VALUES ('20120317002121');

INSERT INTO schema_migrations (version) VALUES ('20120319190458');

INSERT INTO schema_migrations (version) VALUES ('20120319204514');

INSERT INTO schema_migrations (version) VALUES ('20120320151217');

INSERT INTO schema_migrations (version) VALUES ('20120321215952');

INSERT INTO schema_migrations (version) VALUES ('20120321220026');

INSERT INTO schema_migrations (version) VALUES ('20120327173544');

INSERT INTO schema_migrations (version) VALUES ('20120328155859');

INSERT INTO schema_migrations (version) VALUES ('20120402225520');

INSERT INTO schema_migrations (version) VALUES ('20120403191301');

INSERT INTO schema_migrations (version) VALUES ('20120405191313');

INSERT INTO schema_migrations (version) VALUES ('20120409221213');

INSERT INTO schema_migrations (version) VALUES ('20120410004439');

INSERT INTO schema_migrations (version) VALUES ('20120410014453');

INSERT INTO schema_migrations (version) VALUES ('20120419000954');

INSERT INTO schema_migrations (version) VALUES ('20120419005747');

INSERT INTO schema_migrations (version) VALUES ('20120419015341');

INSERT INTO schema_migrations (version) VALUES ('20120419025453');

INSERT INTO schema_migrations (version) VALUES ('20120419033137');

INSERT INTO schema_migrations (version) VALUES ('20120423181301');

INSERT INTO schema_migrations (version) VALUES ('20120423181418');

INSERT INTO schema_migrations (version) VALUES ('20120424131704');

INSERT INTO schema_migrations (version) VALUES ('20120424132249');

INSERT INTO schema_migrations (version) VALUES ('20120424155642');

INSERT INTO schema_migrations (version) VALUES ('20120424161809');

INSERT INTO schema_migrations (version) VALUES ('20120425160252');

INSERT INTO schema_migrations (version) VALUES ('20120501001230');

INSERT INTO schema_migrations (version) VALUES ('20120501001709');

INSERT INTO schema_migrations (version) VALUES ('20120501153125');

INSERT INTO schema_migrations (version) VALUES ('20120501183130');

INSERT INTO schema_migrations (version) VALUES ('20120501215500');

INSERT INTO schema_migrations (version) VALUES ('20120502004641');

INSERT INTO schema_migrations (version) VALUES ('20120502160128');

INSERT INTO schema_migrations (version) VALUES ('20120504034720');

INSERT INTO schema_migrations (version) VALUES ('20120504053532');

INSERT INTO schema_migrations (version) VALUES ('20120504053945');

INSERT INTO schema_migrations (version) VALUES ('20120504055751');

INSERT INTO schema_migrations (version) VALUES ('20120504055901');

INSERT INTO schema_migrations (version) VALUES ('20120509170050');

INSERT INTO schema_migrations (version) VALUES ('20120510130112');

INSERT INTO schema_migrations (version) VALUES ('20120510153651');

INSERT INTO schema_migrations (version) VALUES ('20120511185814');

INSERT INTO schema_migrations (version) VALUES ('20120511191648');

INSERT INTO schema_migrations (version) VALUES ('20120515171018');

INSERT INTO schema_migrations (version) VALUES ('20120517012114');

INSERT INTO schema_migrations (version) VALUES ('20120517130213');

INSERT INTO schema_migrations (version) VALUES ('20120518162529');

INSERT INTO schema_migrations (version) VALUES ('20120518195112');

INSERT INTO schema_migrations (version) VALUES ('20120522025626');

INSERT INTO schema_migrations (version) VALUES ('20120522030047');

INSERT INTO schema_migrations (version) VALUES ('20120522030302');

INSERT INTO schema_migrations (version) VALUES ('20120524220834');

INSERT INTO schema_migrations (version) VALUES ('20120524224947');

INSERT INTO schema_migrations (version) VALUES ('20120525221617');

INSERT INTO schema_migrations (version) VALUES ('20120529182101');

INSERT INTO schema_migrations (version) VALUES ('20120529192221');

INSERT INTO schema_migrations (version) VALUES ('20120531153128');

INSERT INTO schema_migrations (version) VALUES ('20120531154934');

INSERT INTO schema_migrations (version) VALUES ('20120531155034');

INSERT INTO schema_migrations (version) VALUES ('20120607144323');

INSERT INTO schema_migrations (version) VALUES ('20120608183158');

INSERT INTO schema_migrations (version) VALUES ('20120619172729');

INSERT INTO schema_migrations (version) VALUES ('20120619172808');

INSERT INTO schema_migrations (version) VALUES ('20120619172836');

INSERT INTO schema_migrations (version) VALUES ('20120620141314');

INSERT INTO schema_migrations (version) VALUES ('20120620204107');

INSERT INTO schema_migrations (version) VALUES ('20120620215556');

INSERT INTO schema_migrations (version) VALUES ('20120620215944');

INSERT INTO schema_migrations (version) VALUES ('20120628112427');

INSERT INTO schema_migrations (version) VALUES ('20120628120007');

INSERT INTO schema_migrations (version) VALUES ('20120628120010');

INSERT INTO schema_migrations (version) VALUES ('20120702235652');

INSERT INTO schema_migrations (version) VALUES ('20120703125905');

INSERT INTO schema_migrations (version) VALUES ('20120703130106');

INSERT INTO schema_migrations (version) VALUES ('20120705153644');

INSERT INTO schema_migrations (version) VALUES ('20120706041733');

INSERT INTO schema_migrations (version) VALUES ('20120724012116');

INSERT INTO schema_migrations (version) VALUES ('20120725013558');

INSERT INTO schema_migrations (version) VALUES ('20120725013658');

INSERT INTO schema_migrations (version) VALUES ('20120727042803');

INSERT INTO schema_migrations (version) VALUES ('20120806015813');

INSERT INTO schema_migrations (version) VALUES ('20120808061238');

INSERT INTO schema_migrations (version) VALUES ('20120815184600');

INSERT INTO schema_migrations (version) VALUES ('20120816140115');

INSERT INTO schema_migrations (version) VALUES ('20120816140308');

INSERT INTO schema_migrations (version) VALUES ('20120816142313');

INSERT INTO schema_migrations (version) VALUES ('20120820173652');

INSERT INTO schema_migrations (version) VALUES ('20120820185517');

INSERT INTO schema_migrations (version) VALUES ('20120821182948');

INSERT INTO schema_migrations (version) VALUES ('20120824005505');

INSERT INTO schema_migrations (version) VALUES ('20120827213934');

INSERT INTO schema_migrations (version) VALUES ('20120830225105');

INSERT INTO schema_migrations (version) VALUES ('20120901033338');

INSERT INTO schema_migrations (version) VALUES ('20120905222623');

INSERT INTO schema_migrations (version) VALUES ('20120908031541');

INSERT INTO schema_migrations (version) VALUES ('20120910183016');

INSERT INTO schema_migrations (version) VALUES ('20120912204113');

INSERT INTO schema_migrations (version) VALUES ('20120913203210');

INSERT INTO schema_migrations (version) VALUES ('20120927005505');

INSERT INTO schema_migrations (version) VALUES ('20121001131410');

INSERT INTO schema_migrations (version) VALUES ('20121001184843');

INSERT INTO schema_migrations (version) VALUES ('20121002192011');

INSERT INTO schema_migrations (version) VALUES ('20121003203111');

INSERT INTO schema_migrations (version) VALUES ('20121005170854');

INSERT INTO schema_migrations (version) VALUES ('20121016040050');

INSERT INTO schema_migrations (version) VALUES ('20121017165615');

INSERT INTO schema_migrations (version) VALUES ('20121019193831');

INSERT INTO schema_migrations (version) VALUES ('20121019233645');

INSERT INTO schema_migrations (version) VALUES ('20121019233846');

INSERT INTO schema_migrations (version) VALUES ('20121019235818');

INSERT INTO schema_migrations (version) VALUES ('20121020000339');

INSERT INTO schema_migrations (version) VALUES ('20121020000647');

INSERT INTO schema_migrations (version) VALUES ('20121022010437');

INSERT INTO schema_migrations (version) VALUES ('20121030022046');

INSERT INTO schema_migrations (version) VALUES ('20121104185907');

INSERT INTO schema_migrations (version) VALUES ('20121108185627');

INSERT INTO schema_migrations (version) VALUES ('20121108190221');

INSERT INTO schema_migrations (version) VALUES ('20121108191300');

INSERT INTO schema_migrations (version) VALUES ('20121108191315');

INSERT INTO schema_migrations (version) VALUES ('20121121184515');

INSERT INTO schema_migrations (version) VALUES ('20121129025138');

INSERT INTO schema_migrations (version) VALUES ('20121206054207');

INSERT INTO schema_migrations (version) VALUES ('20121207053338');

INSERT INTO schema_migrations (version) VALUES ('20121211035737');

INSERT INTO schema_migrations (version) VALUES ('20121211040121');

INSERT INTO schema_migrations (version) VALUES ('20121211052719');

INSERT INTO schema_migrations (version) VALUES ('20121211053234');

INSERT INTO schema_migrations (version) VALUES ('20121211053848');

INSERT INTO schema_migrations (version) VALUES ('20121211054737');

INSERT INTO schema_migrations (version) VALUES ('20121211061037');

INSERT INTO schema_migrations (version) VALUES ('20121213212413');

INSERT INTO schema_migrations (version) VALUES ('20121217231144');

INSERT INTO schema_migrations (version) VALUES ('20121227233301');

INSERT INTO schema_migrations (version) VALUES ('20121228001629');

INSERT INTO schema_migrations (version) VALUES ('20130104083859');

INSERT INTO schema_migrations (version) VALUES ('20130105165926');

INSERT INTO schema_migrations (version) VALUES ('20130122142327');

INSERT INTO schema_migrations (version) VALUES ('20130122183505');

INSERT INTO schema_migrations (version) VALUES ('20130204202449');

INSERT INTO schema_migrations (version) VALUES ('20130204223212');

INSERT INTO schema_migrations (version) VALUES ('20130206181533');

INSERT INTO schema_migrations (version) VALUES ('20130206220418');

INSERT INTO schema_migrations (version) VALUES ('20130206224236');

INSERT INTO schema_migrations (version) VALUES ('20130211175946');

INSERT INTO schema_migrations (version) VALUES ('20130213035701');

INSERT INTO schema_migrations (version) VALUES ('20130219183627');

INSERT INTO schema_migrations (version) VALUES ('20130301170755');

INSERT INTO schema_migrations (version) VALUES ('20130301180602');

INSERT INTO schema_migrations (version) VALUES ('20130301180839');

INSERT INTO schema_migrations (version) VALUES ('20130307014939');

INSERT INTO schema_migrations (version) VALUES ('20130326184820');

INSERT INTO schema_migrations (version) VALUES ('20130418142401');

INSERT INTO schema_migrations (version) VALUES ('20130422193839');

INSERT INTO schema_migrations (version) VALUES ('20130423214355');

INSERT INTO schema_migrations (version) VALUES ('20130426183058');

INSERT INTO schema_migrations (version) VALUES ('20130426183405');

INSERT INTO schema_migrations (version) VALUES ('20130426195617');

INSERT INTO schema_migrations (version) VALUES ('20130429201006');

INSERT INTO schema_migrations (version) VALUES ('20130502182109');

INSERT INTO schema_migrations (version) VALUES ('20130503041034');

INSERT INTO schema_migrations (version) VALUES ('20130503205852');

INSERT INTO schema_migrations (version) VALUES ('20130503210330');

INSERT INTO schema_migrations (version) VALUES ('20130503210331');

INSERT INTO schema_migrations (version) VALUES ('20130503210333');

INSERT INTO schema_migrations (version) VALUES ('20130509143907');

INSERT INTO schema_migrations (version) VALUES ('20130521024004');

INSERT INTO schema_migrations (version) VALUES ('20130521184823');

INSERT INTO schema_migrations (version) VALUES ('20130521185050');

INSERT INTO schema_migrations (version) VALUES ('20130521185105');

INSERT INTO schema_migrations (version) VALUES ('20130521185223');

INSERT INTO schema_migrations (version) VALUES ('20130521185325');

INSERT INTO schema_migrations (version) VALUES ('20130521185450');

INSERT INTO schema_migrations (version) VALUES ('20130521185556');

INSERT INTO schema_migrations (version) VALUES ('20130521192754');

INSERT INTO schema_migrations (version) VALUES ('20130527220931');

INSERT INTO schema_migrations (version) VALUES ('20130527221911');

INSERT INTO schema_migrations (version) VALUES ('20130527222128');

INSERT INTO schema_migrations (version) VALUES ('20130529223104');

INSERT INTO schema_migrations (version) VALUES ('20130604204726');

INSERT INTO schema_migrations (version) VALUES ('20130604204755');

INSERT INTO schema_migrations (version) VALUES ('20130604204821');

INSERT INTO schema_migrations (version) VALUES ('20130604204845');

INSERT INTO schema_migrations (version) VALUES ('20130604204907');

INSERT INTO schema_migrations (version) VALUES ('20130604222205');

INSERT INTO schema_migrations (version) VALUES ('20130605183727');

INSERT INTO schema_migrations (version) VALUES ('20130606173023');

INSERT INTO schema_migrations (version) VALUES ('20130607235427');

INSERT INTO schema_migrations (version) VALUES ('20130608031607');

INSERT INTO schema_migrations (version) VALUES ('20130613190503');

INSERT INTO schema_migrations (version) VALUES ('20130613202901');

INSERT INTO schema_migrations (version) VALUES ('20130613212532');

INSERT INTO schema_migrations (version) VALUES ('20130614224704');

INSERT INTO schema_migrations (version) VALUES ('20130614225304');

INSERT INTO schema_migrations (version) VALUES ('20130614225524');

INSERT INTO schema_migrations (version) VALUES ('20130617165154');

INSERT INTO schema_migrations (version) VALUES ('20130621211017');

INSERT INTO schema_migrations (version) VALUES ('20130822141303');

INSERT INTO schema_migrations (version) VALUES ('20130822141517');

INSERT INTO schema_migrations (version) VALUES ('20130822153040');

INSERT INTO schema_migrations (version) VALUES ('20130903201018');

INSERT INTO schema_migrations (version) VALUES ('20130903201228');

INSERT INTO schema_migrations (version) VALUES ('20130907143907');

INSERT INTO schema_migrations (version) VALUES ('20130910203819');

INSERT INTO schema_migrations (version) VALUES ('20130926174333');

INSERT INTO schema_migrations (version) VALUES ('20130926174740');

INSERT INTO schema_migrations (version) VALUES ('20130926175308');

INSERT INTO schema_migrations (version) VALUES ('20130926175735');

INSERT INTO schema_migrations (version) VALUES ('20130926221641');

INSERT INTO schema_migrations (version) VALUES ('20130927213218');

INSERT INTO schema_migrations (version) VALUES ('20131022041407');

INSERT INTO schema_migrations (version) VALUES ('20131022045451');

INSERT INTO schema_migrations (version) VALUES ('20131022171328');

INSERT INTO schema_migrations (version) VALUES ('20131022175738');

INSERT INTO schema_migrations (version) VALUES ('20131024201439');

INSERT INTO schema_migrations (version) VALUES ('20131030234207');

INSERT INTO schema_migrations (version) VALUES ('20131031150031');

INSERT INTO schema_migrations (version) VALUES ('20131031151846');

INSERT INTO schema_migrations (version) VALUES ('20131101022739');

INSERT INTO schema_migrations (version) VALUES ('20131101022859');

INSERT INTO schema_migrations (version) VALUES ('20131101025738');

INSERT INTO schema_migrations (version) VALUES ('20131105164530');

INSERT INTO schema_migrations (version) VALUES ('20131105194916');

INSERT INTO schema_migrations (version) VALUES ('20131111145731');

INSERT INTO schema_migrations (version) VALUES ('20131111161615');

INSERT INTO schema_migrations (version) VALUES ('20131111162126');

INSERT INTO schema_migrations (version) VALUES ('20131112001834');

INSERT INTO schema_migrations (version) VALUES ('20131123210042');

INSERT INTO schema_migrations (version) VALUES ('20131123214459');

INSERT INTO schema_migrations (version) VALUES ('20140107195814');

INSERT INTO schema_migrations (version) VALUES ('20140108054346');

INSERT INTO schema_migrations (version) VALUES ('20140113152943');

INSERT INTO schema_migrations (version) VALUES ('20140113153233');

INSERT INTO schema_migrations (version) VALUES ('20140113173229');

INSERT INTO schema_migrations (version) VALUES ('20140113173546');

INSERT INTO schema_migrations (version) VALUES ('20140113180351');

INSERT INTO schema_migrations (version) VALUES ('20140116181607');

INSERT INTO schema_migrations (version) VALUES ('20140117200917');

INSERT INTO schema_migrations (version) VALUES ('20140123013644');

INSERT INTO schema_migrations (version) VALUES ('20140129010331');

INSERT INTO schema_migrations (version) VALUES ('20140210231516');

INSERT INTO schema_migrations (version) VALUES ('20140211220040');

INSERT INTO schema_migrations (version) VALUES ('20140214193506');

INSERT INTO schema_migrations (version) VALUES ('20140214193836');

INSERT INTO schema_migrations (version) VALUES ('20140214194119');

INSERT INTO schema_migrations (version) VALUES ('20140217170434');

INSERT INTO schema_migrations (version) VALUES ('20140221192615');

INSERT INTO schema_migrations (version) VALUES ('20140304201429');

INSERT INTO schema_migrations (version) VALUES ('20140317203652');

INSERT INTO schema_migrations (version) VALUES ('20140319192820');

INSERT INTO schema_migrations (version) VALUES ('20140324183225');

INSERT INTO schema_migrations (version) VALUES ('20140324192347');

INSERT INTO schema_migrations (version) VALUES ('20140326055128');

INSERT INTO schema_migrations (version) VALUES ('20140403130657');

INSERT INTO schema_migrations (version) VALUES ('20140408163129');

INSERT INTO schema_migrations (version) VALUES ('20140410182452');

INSERT INTO schema_migrations (version) VALUES ('20140416184235');

INSERT INTO schema_migrations (version) VALUES ('20140421210008');

INSERT INTO schema_migrations (version) VALUES ('20140501233806');

INSERT INTO schema_migrations (version) VALUES ('20140507220727');

INSERT INTO schema_migrations (version) VALUES ('20140510192350');

INSERT INTO schema_migrations (version) VALUES ('20140510192657');

INSERT INTO schema_migrations (version) VALUES ('20140605151403');

INSERT INTO schema_migrations (version) VALUES ('20140618201210');

INSERT INTO schema_migrations (version) VALUES ('20140624154618');

INSERT INTO schema_migrations (version) VALUES ('20140624211312');

INSERT INTO schema_migrations (version) VALUES ('20140626203723');

INSERT INTO schema_migrations (version) VALUES ('20140627022428');

INSERT INTO schema_migrations (version) VALUES ('20140627022533');

INSERT INTO schema_migrations (version) VALUES ('20140629191108');

INSERT INTO schema_migrations (version) VALUES ('20140629191748');

INSERT INTO schema_migrations (version) VALUES ('20140629191915');

INSERT INTO schema_migrations (version) VALUES ('20140629192019');

INSERT INTO schema_migrations (version) VALUES ('20140629193351');

INSERT INTO schema_migrations (version) VALUES ('20140630182842');

INSERT INTO schema_migrations (version) VALUES ('20140630192016');

INSERT INTO schema_migrations (version) VALUES ('20140630193205');

INSERT INTO schema_migrations (version) VALUES ('20140630225343');

INSERT INTO schema_migrations (version) VALUES ('20140711151619');

INSERT INTO schema_migrations (version) VALUES ('20140714140130');

INSERT INTO schema_migrations (version) VALUES ('20140715193752');

INSERT INTO schema_migrations (version) VALUES ('20140715201115');

INSERT INTO schema_migrations (version) VALUES ('20140731114015');

INSERT INTO schema_migrations (version) VALUES ('20140814213222');

INSERT INTO schema_migrations (version) VALUES ('20140818221006');

INSERT INTO schema_migrations (version) VALUES ('20140820193417');

INSERT INTO schema_migrations (version) VALUES ('20140826145300');

INSERT INTO schema_migrations (version) VALUES ('20140829212030');

INSERT INTO schema_migrations (version) VALUES ('20140917173435');

INSERT INTO schema_migrations (version) VALUES ('20140930200457');

INSERT INTO schema_migrations (version) VALUES ('20141003155347');

INSERT INTO schema_migrations (version) VALUES ('20141010040750');

INSERT INTO schema_migrations (version) VALUES ('20141010045603');

INSERT INTO schema_migrations (version) VALUES ('20141024151713');

INSERT INTO schema_migrations (version) VALUES ('20141027184753');

INSERT INTO schema_migrations (version) VALUES ('20141118201319');

INSERT INTO schema_migrations (version) VALUES ('20141120015159');

INSERT INTO schema_migrations (version) VALUES ('20141120183556');

INSERT INTO schema_migrations (version) VALUES ('20141125211757');

INSERT INTO schema_migrations (version) VALUES ('20141125225527');

INSERT INTO schema_migrations (version) VALUES ('20141125230155');

INSERT INTO schema_migrations (version) VALUES ('20141204163935');

INSERT INTO schema_migrations (version) VALUES ('20141204171132');

INSERT INTO schema_migrations (version) VALUES ('20141208163305');

INSERT INTO schema_migrations (version) VALUES ('20141216174740');

INSERT INTO schema_migrations (version) VALUES ('20150102215927');

INSERT INTO schema_migrations (version) VALUES ('20150107201354');

INSERT INTO schema_migrations (version) VALUES ('20150107202753');

INSERT INTO schema_migrations (version) VALUES ('20150107204858');

INSERT INTO schema_migrations (version) VALUES ('20150108220636');

INSERT INTO schema_migrations (version) VALUES ('20150111220256');

INSERT INTO schema_migrations (version) VALUES ('20150111220313');

INSERT INTO schema_migrations (version) VALUES ('20150130224716');

INSERT INTO schema_migrations (version) VALUES ('20150203194323');

INSERT INTO schema_migrations (version) VALUES ('20150203194337');

INSERT INTO schema_migrations (version) VALUES ('20150210200137');

INSERT INTO schema_migrations (version) VALUES ('20150305162024');

INSERT INTO schema_migrations (version) VALUES ('20150409152145');

INSERT INTO schema_migrations (version) VALUES ('20150409153006');

INSERT INTO schema_migrations (version) VALUES ('20150409154101');

INSERT INTO schema_migrations (version) VALUES ('20150409162207');

INSERT INTO schema_migrations (version) VALUES ('20150410205627');

INSERT INTO schema_migrations (version) VALUES ('20150410213415');

INSERT INTO schema_migrations (version) VALUES ('20150414023218');

INSERT INTO schema_migrations (version) VALUES ('20150414023501');

INSERT INTO schema_migrations (version) VALUES ('20150420131548');

INSERT INTO schema_migrations (version) VALUES ('20150428131528');

INSERT INTO schema_migrations (version) VALUES ('20150503210938');

INSERT INTO schema_migrations (version) VALUES ('20150508200845');

INSERT INTO schema_migrations (version) VALUES ('20150513004314');

INSERT INTO schema_migrations (version) VALUES ('20150513214316');

INSERT INTO schema_migrations (version) VALUES ('20150518183228');

INSERT INTO schema_migrations (version) VALUES ('20150518183547');

INSERT INTO schema_migrations (version) VALUES ('20150518185411');

INSERT INTO schema_migrations (version) VALUES ('20150518185832');

INSERT INTO schema_migrations (version) VALUES ('20150522155809');

INSERT INTO schema_migrations (version) VALUES ('20150523151050');

INSERT INTO schema_migrations (version) VALUES ('20150523152338');

INSERT INTO schema_migrations (version) VALUES ('20150523221424');

INSERT INTO schema_migrations (version) VALUES ('20150602164703');

INSERT INTO schema_migrations (version) VALUES ('20150602164808');

INSERT INTO schema_migrations (version) VALUES ('20150609181413');

INSERT INTO schema_migrations (version) VALUES ('20150609220156');

INSERT INTO schema_migrations (version) VALUES ('20150619032522');

INSERT INTO schema_migrations (version) VALUES ('20150622150226');

INSERT INTO schema_migrations (version) VALUES ('20150717184324');

INSERT INTO schema_migrations (version) VALUES ('20150720200541');

INSERT INTO schema_migrations (version) VALUES ('20150723172220');

INSERT INTO schema_migrations (version) VALUES ('20150730154029');

INSERT INTO schema_migrations (version) VALUES ('20150731223735');

INSERT INTO schema_migrations (version) VALUES ('20150804163342');

INSERT INTO schema_migrations (version) VALUES ('20150814195019');

INSERT INTO schema_migrations (version) VALUES ('20150818202759');

INSERT INTO schema_migrations (version) VALUES ('20150821144231');

INSERT INTO schema_migrations (version) VALUES ('20151008193453');

INSERT INTO schema_migrations (version) VALUES ('20151020184726');

INSERT INTO schema_migrations (version) VALUES ('20151020185018');

INSERT INTO schema_migrations (version) VALUES ('20151021144605');

INSERT INTO schema_migrations (version) VALUES ('20151023145023');

INSERT INTO schema_migrations (version) VALUES ('20151106225413');

INSERT INTO schema_migrations (version) VALUES ('20151111004226');

INSERT INTO schema_migrations (version) VALUES ('20151112192400');

INSERT INTO schema_migrations (version) VALUES ('20151119181923');

INSERT INTO schema_migrations (version) VALUES ('20151125170439');

INSERT INTO schema_migrations (version) VALUES ('20151125170657');

INSERT INTO schema_migrations (version) VALUES ('20151125171138');

INSERT INTO schema_migrations (version) VALUES ('20151125173402');

INSERT INTO schema_migrations (version) VALUES ('20151125230751');

INSERT INTO schema_migrations (version) VALUES ('20151214163302');

INSERT INTO schema_migrations (version) VALUES ('20160307192607');

INSERT INTO schema_migrations (version) VALUES ('20160307232457');

INSERT INTO schema_migrations (version) VALUES ('20160316131516');

INSERT INTO schema_migrations (version) VALUES ('20160316131535');

INSERT INTO schema_migrations (version) VALUES ('20160401203518');

INSERT INTO schema_migrations (version) VALUES ('20160406212829');

INSERT INTO schema_migrations (version) VALUES ('20160425164120');

INSERT INTO schema_migrations (version) VALUES ('20160614183835');