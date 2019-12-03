
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `affiliate_feature_additions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affiliate_feature_additions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliate_feature_additions_on_affiliate_id_and_feature_id` (`affiliate_id`,`feature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `affiliate_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affiliate_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) NOT NULL,
  `template_class` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `available` tinyint(1) NOT NULL DEFAULT '1',
  `template_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliate_templates_on_affiliate_id_and_template_class` (`affiliate_id`,`template_class`),
  UNIQUE KEY `index_affiliate_templates_on_affiliate_id_and_template_id` (`affiliate_id`,`template_id`),
  KEY `index_affiliate_templates_on_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `affiliate_twitter_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `affiliates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affiliates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `has_staged_content` tinyint(1) NOT NULL DEFAULT '0',
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_sayt_enabled` tinyint(1) DEFAULT '1',
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `external_css_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `favicon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `css_properties` mediumtext COLLATE utf8mb4_unicode_ci,
  `theme` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'en',
  `scope_ids` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_medline_govbox_enabled` tinyint(1) DEFAULT '0',
  `previous_fields_json` longtext COLLATE utf8mb4_unicode_ci,
  `live_fields_json` longtext COLLATE utf8mb4_unicode_ci,
  `staged_fields_json` longtext COLLATE utf8mb4_unicode_ci,
  `uses_managed_header_footer` tinyint(1) DEFAULT NULL,
  `staged_uses_managed_header_footer` tinyint(1) DEFAULT NULL,
  `rackspace_header_image_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_header_image_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_header_image_file_size` int(11) DEFAULT NULL,
  `rackspace_header_image_updated_at` datetime DEFAULT NULL,
  `fetch_concurrency` int(11) NOT NULL DEFAULT '1',
  `default_search_label` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_related_searches_enabled` tinyint(1) DEFAULT '1',
  `left_nav_label` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ga_web_property_id` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_page_background_image_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_page_background_image_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_page_background_image_file_size` int(11) DEFAULT NULL,
  `rackspace_page_background_image_updated_at` datetime DEFAULT NULL,
  `is_photo_govbox_enabled` tinyint(1) DEFAULT '0',
  `rackspace_mobile_logo_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_mobile_logo_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_mobile_logo_file_size` int(11) DEFAULT NULL,
  `rackspace_mobile_logo_updated_at` datetime DEFAULT NULL,
  `jobs_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `agency_id` int(11) DEFAULT NULL,
  `raw_log_access_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `search_engine` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BingV7',
  `is_rss_govbox_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `rss_govbox_label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_video_govbox_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `dap_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `dublin_core_mappings` mediumtext COLLATE utf8mb4_unicode_ci,
  `force_mobile_format` tinyint(1) NOT NULL DEFAULT '1',
  `gets_blended_results` tinyint(1) NOT NULL DEFAULT '0',
  `is_bing_image_search_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `is_federal_register_document_govbox_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `google_cx` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `google_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_access_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gets_commercial_results_on_blended_search` tinyint(1) NOT NULL DEFAULT '1',
  `gets_i14y_results` tinyint(1) NOT NULL DEFAULT '0',
  `rackspace_header_tagline_logo_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_header_tagline_logo_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_header_tagline_logo_file_size` int(11) DEFAULT NULL,
  `rackspace_header_tagline_logo_updated_at` datetime DEFAULT NULL,
  `search_consumer_search_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `domain_control_validation_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `i14y_date_stamp_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `active_template_id` int(11) DEFAULT NULL,
  `template_schema` mediumtext COLLATE utf8mb4_unicode_ci,
  `page_background_image_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_background_image_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_background_image_file_size` int(11) DEFAULT NULL,
  `page_background_image_updated_at` datetime DEFAULT NULL,
  `header_image_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `header_image_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `header_image_file_size` int(11) DEFAULT NULL,
  `header_image_updated_at` datetime DEFAULT NULL,
  `mobile_logo_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile_logo_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile_logo_file_size` int(11) DEFAULT NULL,
  `mobile_logo_updated_at` datetime DEFAULT NULL,
  `header_tagline_logo_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `header_tagline_logo_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `header_tagline_logo_file_size` int(11) DEFAULT NULL,
  `header_tagline_logo_updated_at` datetime DEFAULT NULL,
  `template_id` int(11) DEFAULT NULL,
  `bing_v5_key` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliates_on_name` (`name`),
  KEY `index_affiliates_on_active_template_id` (`active_template_id`),
  KEY `index_affiliates_on_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `affiliates_instagram_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affiliates_instagram_profiles` (
  `affiliate_id` int(11) NOT NULL,
  `instagram_profile_id` bigint(20) NOT NULL,
  UNIQUE KEY `index_affiliates_instagram_profiles` (`affiliate_id`,`instagram_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `affiliates_youtube_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affiliates_youtube_profiles` (
  `affiliate_id` int(11) DEFAULT NULL,
  `youtube_profile_id` int(11) DEFAULT NULL,
  UNIQUE KEY `affiliate_id_youtube_profile_id` (`affiliate_id`,`youtube_profile_id`),
  KEY `index_affiliates_youtube_profiles_on_youtube_profile_id` (`youtube_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `agencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `abbreviation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `federal_register_agency_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `agency_organization_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agency_organization_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agency_id` int(11) DEFAULT NULL,
  `organization_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_agency_organization_codes_on_agency_id` (`agency_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `agency_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agency_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phrase` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agency_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_agency_queries_on_phrase` (`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `text` mediumtext COLLATE utf8mb4_unicode_ci,
  `title` mediumtext COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_alerts_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `boosted_content_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boosted_content_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `boosted_content_id` int(11) NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_boosted_content_keywords_on_boosted_content_id` (`boosted_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `boosted_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boosted_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `publish_start_on` date NOT NULL,
  `publish_end_on` date DEFAULT NULL,
  `match_keyword_values_only` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_boosted_contents_on_affiliate_id_and_title` (`affiliate_id`,`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `catalog_prefixes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_prefixes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `connected_affiliate_id` int(11) NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` int(11) NOT NULL DEFAULT '100',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_connections_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `document_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sitelink_generator_names` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `advanced_search_enabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_document_collections_on_affiliate_id_and_name` (`affiliate_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `email_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` mediumtext COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `excluded_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `excluded_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_excluded_domains_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `excluded_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `excluded_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` mediumtext COLLATE utf8mb4_unicode_ci,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_excluded_urls_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `featured_collection_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `featured_collection_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `featured_collection_id` int(11) NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_featured_collection_keywords_on_featured_collection_id` (`featured_collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `featured_collection_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `featured_collection_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `featured_collection_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_featured_collection_links_on_featured_collection_id` (`featured_collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `featured_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `featured_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `publish_start_on` date NOT NULL,
  `publish_end_on` date DEFAULT NULL,
  `rackspace_image_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_image_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rackspace_image_file_size` int(11) DEFAULT NULL,
  `rackspace_image_updated_at` datetime DEFAULT NULL,
  `image_alt_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `match_keyword_values_only` tinyint(1) DEFAULT '0',
  `image_file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_featured_collections_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_features_on_internal_name` (`internal_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `federal_register_agencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federal_register_agencies` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `last_load_documents_requested_at` datetime DEFAULT NULL,
  `last_successful_load_documents_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `federal_register_agencies_federal_register_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federal_register_agencies_federal_register_documents` (
  `federal_register_agency_id` int(11) NOT NULL,
  `federal_register_document_id` int(11) NOT NULL,
  UNIQUE KEY `index_federal_register_agencies_federal_register_documents` (`federal_register_agency_id`,`federal_register_document_id`),
  KEY `fra_frd_frdocid_idx` (`federal_register_document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `federal_register_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federal_register_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `abstract` mediumtext COLLATE utf8mb4_unicode_ci,
  `html_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_page` int(11) NOT NULL,
  `end_page` int(11) NOT NULL,
  `page_length` int(11) NOT NULL,
  `publication_date` date NOT NULL,
  `comments_close_on` date DEFAULT NULL,
  `effective_on` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `docket_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `significant` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `flickr_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flickr_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_flickr_profiles_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `help_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `help_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `help_page_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_help_links_on_request_path` (`request_path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `hints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hints_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `i14y_drawers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `i14y_drawers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `handle` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `i14y_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `i14y_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `i14y_drawer_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_i14y_memberships_on_affiliate_id_and_i14y_drawer_id` (`affiliate_id`,`i14y_drawer_id`),
  KEY `index_i14y_memberships_on_i14y_drawer_id` (`i14y_drawer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `image_search_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_search_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_image_search_labels_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `indexed_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `indexed_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` mediumtext COLLATE utf8mb4_unicode_ci,
  `description` mediumtext COLLATE utf8mb4_unicode_ci,
  `url` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `body` longtext COLLATE utf8mb4_unicode_ci,
  `doctype` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_crawled_at` datetime DEFAULT NULL,
  `last_crawl_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `load_time` int(11) DEFAULT NULL,
  `source` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'rss',
  `published_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_indexed_documents_on_affiliate_id_and_id` (`affiliate_id`,`id`),
  KEY `by_aid_url` (`affiliate_id`,`url`(50))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `instagram_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instagram_profiles` (
  `id` bigint(20) NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_google_supported` tinyint(1) NOT NULL DEFAULT '0',
  `is_bing_supported` tinyint(1) NOT NULL DEFAULT '0',
  `rtl` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `inferred_country_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_azure_supported` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `med_related_topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `med_related_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `med_topic_id` int(11) NOT NULL,
  `related_medline_tid` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_related_topics_on_med_topic_id` (`med_topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `med_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `med_sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `med_topic_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_sites_on_med_topic_id` (`med_topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `med_synonyms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `med_synonyms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medline_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `topic_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_synonyms_on_medline_title` (`medline_title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `med_topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `med_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medline_tid` int(11) DEFAULT NULL,
  `medline_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medline_url` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `locale` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `summary_html` mediumtext COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_med_topics_on_medline_tid` (`medline_tid`),
  KEY `index_med_topics_on_medline_title` (`medline_title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `misspellings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `misspellings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wrong` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rite` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_misspellings_on_wrong` (`wrong`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `navigations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `navigations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `navigable_id` int(11) NOT NULL,
  `navigable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` int(11) NOT NULL DEFAULT '100',
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_navigations_on_affiliate_id` (`affiliate_id`),
  KEY `index_navigations_on_navigable_id_and_navigable_type` (`navigable_id`,`navigable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `news_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8mb4_unicode_ci,
  `published_at` datetime NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `rss_feed_url_id` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `contributor` mediumtext COLLATE utf8mb4_unicode_ci,
  `subject` mediumtext COLLATE utf8mb4_unicode_ci,
  `publisher` mediumtext COLLATE utf8mb4_unicode_ci,
  `properties` mediumtext COLLATE utf8mb4_unicode_ci,
  `body` longtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_news_items_on_rss_feed_url_id_and_link` (`rss_feed_url_id`,`link`),
  KEY `index_news_items_on_link` (`link`),
  KEY `index_news_items_on_rss_feed_url_id_and_guid` (`rss_feed_url_id`,`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `outbound_rate_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outbound_rate_limits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `limit` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `interval` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'day',
  PRIMARY KEY (`id`),
  KEY `index_outbound_rate_limits_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `routed_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routed_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) DEFAULT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_routed_queries_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `routed_query_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routed_query_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `routed_query_id` int(11) DEFAULT NULL,
  `keyword` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_routed_query_keywords_on_routed_query_id_and_keyword` (`routed_query_id`,`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rss_feed_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rss_feed_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rss_feed_owner_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_crawled_at` datetime DEFAULT NULL,
  `last_crawl_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `language` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oasis_mrss_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rss_feed_urls_on_rss_feed_owner_type_and_url` (`rss_feed_owner_type`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rss_feed_urls_rss_feeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rss_feed_urls_rss_feeds` (
  `rss_feed_url_id` int(11) NOT NULL,
  `rss_feed_id` int(11) NOT NULL,
  UNIQUE KEY `index_rss_feed_urls_rss_feeds_on_rss_feed_id_and_rss_feed_url_id` (`rss_feed_id`,`rss_feed_url_id`),
  KEY `index_rss_feed_urls_rss_feeds_on_rss_feed_url_id` (`rss_feed_url_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rss_feeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rss_feeds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_managed` tinyint(1) NOT NULL DEFAULT '0',
  `is_video` tinyint(1) NOT NULL DEFAULT '0',
  `owner_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `show_only_media_content` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_rss_feeds_on_affiliate_id` (`owner_id`),
  KEY `index_rss_feeds_on_owner_type_and_owner_id` (`owner_type`,`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sayt_filters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sayt_filters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phrase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `filter_only_exact_phrase` tinyint(1) NOT NULL DEFAULT '0',
  `is_regex` tinyint(1) NOT NULL DEFAULT '0',
  `accept` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sayt_filters_on_phrase` (`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sayt_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sayt_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phrase` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `popularity` int(11) NOT NULL DEFAULT '1',
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `is_protected` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `is_whitelisted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sayt_suggestions_on_affiliate_id_and_phrase` (`affiliate_id`,`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `search_modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_modules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_search_modules_on_tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `searchgov_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `searchgov_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clean_urls` tinyint(1) NOT NULL DEFAULT '1',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `urls_count` int(11) NOT NULL DEFAULT '0',
  `unfetched_urls_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `scheme` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'http',
  `activity` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'idle',
  `canonical_domain` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_searchgov_domains_on_domain` (`domain`(100)),
  KEY `index_searchgov_domains_on_status` (`status`(100)),
  KEY `index_searchgov_domains_on_activity` (`activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `searchgov_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `searchgov_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `last_crawled_at` datetime DEFAULT NULL,
  `last_crawl_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `load_time` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `searchgov_domain_id` int(11) DEFAULT NULL,
  `lastmod` datetime DEFAULT NULL,
  `enqueued_for_reindex` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_searchgov_urls_on_url` (`url`(255)),
  KEY `index_searchgov_urls_on_searchgov_domain_id` (`searchgov_domain_id`),
  CONSTRAINT `fk_rails_3dd990e08e` FOREIGN KEY (`searchgov_domain_id`) REFERENCES `searchgov_domains` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `site_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `site_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `domain` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_domains_on_affiliate_id_and_domain` (`affiliate_id`,`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `site_feed_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_feed_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `rss_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_fetch_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `last_checked_at` datetime DEFAULT NULL,
  `quota` int(11) NOT NULL DEFAULT '1000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_feed_urls_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sitemaps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sitemaps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `searchgov_domain_id` int(11) DEFAULT NULL,
  `url` varchar(2000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_crawl_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_crawled_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sitemaps_on_searchgov_domain_id` (`searchgov_domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `suggestion_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suggestion_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_suggestion_blocks_on_query` (`query`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `superfresh_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `superfresh_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` mediumtext COLLATE utf8mb4_unicode_ci,
  `affiliate_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_superfresh_urls_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `system_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tag_filters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_filters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `affiliate_id` int(11) NOT NULL,
  `tag` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exclude` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tag_filters_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `klass` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_templates_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `top_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_top_searches_on_position_and_affiliate_id` (`position`,`affiliate_id`),
  KEY `index_top_searches_on_affiliate_id` (`affiliate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tweets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tweet_id` bigint(20) unsigned NOT NULL,
  `tweet_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `twitter_profile_id` bigint(20) unsigned NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `urls` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tweets_on_tweet_id` (`tweet_id`),
  KEY `index_tweets_on_twitter_profile_id` (`twitter_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `twitter_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twitter_lists` (
  `id` bigint(20) unsigned NOT NULL,
  `member_ids` longtext COLLATE utf8mb4_unicode_ci,
  `last_status_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `statuses_updated_at` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  UNIQUE KEY `index_twitter_lists_on_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `twitter_lists_twitter_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twitter_lists_twitter_profiles` (
  `twitter_list_id` bigint(20) unsigned NOT NULL,
  `twitter_profile_id` int(11) NOT NULL,
  UNIQUE KEY `twitter_list_id_profile_id` (`twitter_list_id`,`twitter_profile_id`),
  KEY `index_twitter_lists_twitter_profiles_on_twitter_profile_id` (`twitter_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `twitter_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twitter_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `twitter_id` bigint(20) unsigned NOT NULL,
  `screen_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `profile_image_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_twitter_profiles_on_twitter_id` (`twitter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `url_prefixes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `url_prefixes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_collection_id` int(11) NOT NULL,
  `prefix` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_url_prefixes_on_document_collection_id_and_prefix` (`document_collection_id`,`prefix`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `perishable_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `persistence_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `is_affiliate_admin` tinyint(1) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_login_ip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `contact_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_affiliate` tinyint(1) NOT NULL DEFAULT '1',
  `organization_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_key` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verification_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `welcome_email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `requires_manual_approval` tinyint(1) DEFAULT '0',
  `default_affiliate_id` int(11) DEFAULT NULL,
  `sees_filtered_totals` tinyint(1) NOT NULL DEFAULT '1',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `password_updated_at` datetime DEFAULT NULL,
  `uid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_api_key` (`api_key`),
  UNIQUE KEY `index_users_on_email_verification_token` (`email_verification_token`),
  KEY `index_users_on_perishable_token` (`perishable_token`),
  KEY `index_users_on_uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `watchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `watchers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_interval` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `throttle_period` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conditions` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_window` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `query_blocklist` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `whitelisted_v1_api_handles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whitelisted_v1_api_handles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `handle` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_whitelisted_v1_api_handles_on_handle` (`handle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `youtube_playlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `youtube_playlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `youtube_profile_id` int(11) DEFAULT NULL,
  `playlist_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `etag` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `news_item_ids` longtext COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_youtube_playlists_on_youtube_profile_id_and_playlist_id` (`youtube_profile_id`,`playlist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `youtube_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `youtube_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `channel_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `imported_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_youtube_profiles_on_channel_id` (`channel_id`),
  KEY `index_youtube_profiles_on_id_and_imported_at` (`id`,`imported_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20090818003200'),
('20090827135344'),
('20090830131735'),
('20090830133721'),
('20090830141034'),
('20090830142140'),
('20090830150517'),
('20090914192607'),
('20090914213039'),
('20090916135047'),
('20090924003837'),
('20090924003859'),
('20090924004347'),
('20090929171657'),
('20090930030530'),
('20091001185128'),
('20091015151736'),
('20091015181123'),
('20091029223615'),
('20091030151924'),
('20091106004909'),
('20091208191125'),
('20091210011500'),
('20091215192012'),
('20091218221303'),
('20091218235406'),
('20091219000213'),
('20091221202159'),
('20091221232552'),
('20100105214058'),
('20100120053149'),
('20100120201026'),
('20100121191230'),
('20100121191454'),
('20100122184251'),
('20100122190015'),
('20100122191430'),
('20100122220402'),
('20100124175356'),
('20100124180513'),
('20100126150542'),
('20100128125151'),
('20100129060051'),
('20100202025450'),
('20100202025510'),
('20100203232752'),
('20100302150635'),
('20100306210751'),
('20100306212231'),
('20100306213431'),
('20100310002858'),
('20100310003126'),
('20100310003534'),
('20100310163117'),
('20100313165633'),
('20100316202847'),
('20100319173135'),
('20100319181609'),
('20100321171719'),
('20100324024956'),
('20100325174330'),
('20100401021109'),
('20100401180826'),
('20100401210327'),
('20100402221817'),
('20100406005620'),
('20100407042525'),
('20100409141457'),
('20100411173938'),
('20100413141407'),
('20100413145803'),
('20100413154957'),
('20100415211606'),
('20100415211705'),
('20100419192955'),
('20100420213732'),
('20100423003915'),
('20100423004410'),
('20100423010137'),
('20100427215756'),
('20100429115931'),
('20100505031121'),
('20100526171400'),
('20100615221009'),
('20100615221025'),
('20100615221855'),
('20100615222319'),
('20100623143038'),
('20100623150837'),
('20100623151105'),
('20100623173419'),
('20100801234616'),
('20100803190405'),
('20100805171609'),
('20100813141129'),
('20100819135950'),
('20100819152301'),
('20100819182653'),
('20100824174959'),
('20100827144830'),
('20100908135939'),
('20100912060038'),
('20100913201908'),
('20100914213333'),
('20100914222343'),
('20100917164414'),
('20100923160526'),
('20100923161556'),
('20100927034711'),
('20100927131049'),
('20100928000201'),
('20100928000646'),
('20100929205439'),
('20100929214757'),
('20100930182206'),
('20101003191357'),
('20101007221355'),
('20101007232915'),
('20101012191557'),
('20101013200500'),
('20101013203634'),
('20101019134728'),
('20101022163543'),
('20101028220805'),
('20101108142930'),
('20101108223719'),
('20101108223827'),
('20101110214355'),
('20101110234928'),
('20101117185756'),
('20101118143644'),
('20101118161945'),
('20101123220917'),
('20101210014112'),
('20101210021715'),
('20101222015949'),
('20110103071549'),
('20110106001640'),
('20110106150740'),
('20110111175041'),
('20110113235733'),
('20110114010639'),
('20110124181045'),
('20110125175354'),
('20110125192541'),
('20110125194002'),
('20110127195543'),
('20110128183710'),
('20110203181742'),
('20110204160803'),
('20110204195947'),
('20110204200027'),
('20110208115622'),
('20110211164031'),
('20110211210757'),
('20110216004225'),
('20110225142438'),
('20110225185031'),
('20110301163608'),
('20110301163712'),
('20110302225332'),
('20110303005150'),
('20110303155705'),
('20110304145634'),
('20110316144126'),
('20110317221114'),
('20110318115823'),
('20110328225035'),
('20110328231258'),
('20110328233426'),
('20110328234107'),
('20110329044945'),
('20110329045844'),
('20110329050058'),
('20110329050302'),
('20110330212048'),
('20110331212739'),
('20110331213758'),
('20110401215815'),
('20110404130848'),
('20110407141548'),
('20110411123231'),
('20110419195340'),
('20110420223513'),
('20110423194742'),
('20110425041201'),
('20110425182649'),
('20110512160939'),
('20110513001443'),
('20110602132347'),
('20110602164037'),
('20110603161852'),
('20110603204350'),
('20110607192052'),
('20110609125539'),
('20110610224518'),
('20110610225954'),
('20110621205934'),
('20110706013212'),
('20110715175055'),
('20110715175134'),
('20110715175201'),
('20110722233615'),
('20110727180259'),
('20110801215424'),
('20110801220700'),
('20110802190415'),
('20110802190508'),
('20110811165030'),
('20110813150408'),
('20110813150925'),
('20110815164006'),
('20110815202652'),
('20110819063140'),
('20110820030917'),
('20110822152349'),
('20110822160220'),
('20110823044733'),
('20110829215806'),
('20110831215243'),
('20110831220908'),
('20110901045031'),
('20110901045151'),
('20110912160352'),
('20110912222019'),
('20110913050747'),
('20110914143122'),
('20110914204915'),
('20110915172744'),
('20110916015126'),
('20110916141952'),
('20110926194832'),
('20110926225428'),
('20110926230137'),
('20110926233554'),
('20110928173111'),
('20110930175157'),
('20111004150008'),
('20111004150929'),
('20111005135312'),
('20111005140949'),
('20111007140523'),
('20111013220704'),
('20111013230036'),
('20111014145612'),
('20111015010710'),
('20111017155756'),
('20111017175410'),
('20111019184243'),
('20111025135656'),
('20111028041409'),
('20111028181817'),
('20111031142229'),
('20111103131805'),
('20111107164015'),
('20111109175611'),
('20111109202025'),
('20111115140559'),
('20111116000953'),
('20111116155052'),
('20111121160027'),
('20111121201602'),
('20111123194534'),
('20111123212028'),
('20111129163521'),
('20111129192643'),
('20111130175117'),
('20111205205515'),
('20111214221958'),
('20111214230059'),
('20111216181022'),
('20111216181023'),
('20111220072415'),
('20111220080239'),
('20111221214128'),
('20111223182349'),
('20111223185253'),
('20111227193551'),
('20111231170242'),
('20111231231620'),
('20120103164925'),
('20120105184148'),
('20120106033207'),
('20120106034114'),
('20120108063217'),
('20120108063305'),
('20120109155826'),
('20120110175025'),
('20120117142157'),
('20120117143759'),
('20120119173016'),
('20120123150805'),
('20120124175734'),
('20120131070052'),
('20120202223824'),
('20120206042507'),
('20120207032127'),
('20120207192617'),
('20120209184735'),
('20120210000606'),
('20120210002248'),
('20120214020545'),
('20120217154658'),
('20120217154818'),
('20120222190534'),
('20120224042646'),
('20120224194438'),
('20120302183638'),
('20120305164845'),
('20120306153732'),
('20120306160329'),
('20120306163134'),
('20120306184550'),
('20120307160707'),
('20120309023914'),
('20120309023945'),
('20120314001622'),
('20120315135638'),
('20120317001910'),
('20120317002121'),
('20120319190458'),
('20120319204514'),
('20120320151217'),
('20120321215952'),
('20120321220026'),
('20120327173544'),
('20120328155859'),
('20120402225520'),
('20120403191301'),
('20120405191313'),
('20120409221213'),
('20120410004439'),
('20120410014453'),
('20120419000954'),
('20120419005747'),
('20120419015341'),
('20120419025453'),
('20120419033137'),
('20120423181301'),
('20120423181418'),
('20120424131704'),
('20120424132249'),
('20120424155642'),
('20120424161809'),
('20120425160252'),
('20120501001230'),
('20120501001709'),
('20120501153125'),
('20120501183130'),
('20120501215500'),
('20120502004641'),
('20120502160128'),
('20120504034720'),
('20120504053532'),
('20120504053945'),
('20120504055751'),
('20120504055901'),
('20120509170050'),
('20120510130112'),
('20120510153651'),
('20120511185814'),
('20120511191648'),
('20120515171018'),
('20120517012114'),
('20120517130213'),
('20120518162529'),
('20120518195112'),
('20120522025626'),
('20120522030047'),
('20120522030302'),
('20120524220834'),
('20120524224947'),
('20120525221617'),
('20120529182101'),
('20120529192221'),
('20120531153128'),
('20120531154934'),
('20120531155034'),
('20120607144323'),
('20120608183158'),
('20120619172729'),
('20120619172808'),
('20120619172836'),
('20120620141314'),
('20120620204107'),
('20120620215556'),
('20120620215944'),
('20120628112427'),
('20120628120007'),
('20120628120010'),
('20120702235652'),
('20120703125905'),
('20120703130106'),
('20120705153644'),
('20120706041733'),
('20120724012116'),
('20120725013558'),
('20120725013658'),
('20120727042803'),
('20120806015813'),
('20120808061238'),
('20120815184600'),
('20120816140115'),
('20120816140308'),
('20120816142313'),
('20120820173652'),
('20120820185517'),
('20120821182948'),
('20120824005505'),
('20120827213934'),
('20120830225105'),
('20120901033338'),
('20120905222623'),
('20120908031541'),
('20120910183016'),
('20120912204113'),
('20120913203210'),
('20120927005505'),
('20121001131410'),
('20121001184843'),
('20121002192011'),
('20121003203111'),
('20121005170854'),
('20121016040050'),
('20121017165615'),
('20121019193831'),
('20121019233645'),
('20121019233846'),
('20121019235818'),
('20121020000339'),
('20121020000647'),
('20121022010437'),
('20121030022046'),
('20121104185907'),
('20121108185627'),
('20121108190221'),
('20121108191300'),
('20121108191315'),
('20121121184515'),
('20121129025138'),
('20121206054207'),
('20121207053338'),
('20121211035737'),
('20121211040121'),
('20121211052719'),
('20121211053234'),
('20121211053848'),
('20121211054737'),
('20121211061037'),
('20121213212413'),
('20121217231144'),
('20121227233301'),
('20121228001629'),
('20130104083859'),
('20130105165926'),
('20130122142327'),
('20130122183505'),
('20130204202449'),
('20130204223212'),
('20130206181533'),
('20130206220418'),
('20130206224236'),
('20130211175946'),
('20130213035701'),
('20130219183627'),
('20130301170755'),
('20130301180602'),
('20130301180839'),
('20130307014939'),
('20130326184820'),
('20130418142401'),
('20130422193839'),
('20130423214355'),
('20130426183058'),
('20130426183405'),
('20130426195617'),
('20130429201006'),
('20130502182109'),
('20130503041034'),
('20130503205852'),
('20130503210330'),
('20130503210331'),
('20130503210333'),
('20130509143907'),
('20130521024004'),
('20130521184823'),
('20130521185050'),
('20130521185105'),
('20130521185223'),
('20130521185325'),
('20130521185450'),
('20130521185556'),
('20130521192754'),
('20130527220931'),
('20130527221911'),
('20130527222128'),
('20130529223104'),
('20130604204726'),
('20130604204755'),
('20130604204821'),
('20130604204845'),
('20130604204907'),
('20130604222205'),
('20130605183727'),
('20130606173023'),
('20130607235427'),
('20130608031607'),
('20130613190503'),
('20130613202901'),
('20130613212532'),
('20130614224704'),
('20130614225304'),
('20130614225524'),
('20130617165154'),
('20130621211017'),
('20130822141303'),
('20130822141517'),
('20130822153040'),
('20130903201018'),
('20130903201228'),
('20130907143907'),
('20130910203819'),
('20130926174333'),
('20130926174740'),
('20130926175308'),
('20130926175735'),
('20130926221641'),
('20130927213218'),
('20131022041407'),
('20131022045451'),
('20131022171328'),
('20131022175738'),
('20131024201439'),
('20131030234207'),
('20131031150031'),
('20131031151846'),
('20131101022739'),
('20131101022859'),
('20131101025738'),
('20131105164530'),
('20131105194916'),
('20131111145731'),
('20131111161615'),
('20131111162126'),
('20131112001834'),
('20131123210042'),
('20131123214459'),
('20140107195814'),
('20140108054346'),
('20140113152943'),
('20140113153233'),
('20140113173229'),
('20140113173546'),
('20140113180351'),
('20140116181607'),
('20140117200917'),
('20140123013644'),
('20140129010331'),
('20140210231516'),
('20140211220040'),
('20140214193506'),
('20140214193836'),
('20140214194119'),
('20140217170434'),
('20140221192615'),
('20140304201429'),
('20140317203652'),
('20140319192820'),
('20140324183225'),
('20140324192347'),
('20140326055128'),
('20140403130657'),
('20140408163129'),
('20140410182452'),
('20140416184235'),
('20140421210008'),
('20140501233806'),
('20140507220727'),
('20140510192350'),
('20140510192657'),
('20140605151403'),
('20140618201210'),
('20140624154618'),
('20140624211312'),
('20140626203723'),
('20140627022428'),
('20140627022533'),
('20140629191108'),
('20140629191748'),
('20140629191915'),
('20140629192019'),
('20140629193351'),
('20140630182842'),
('20140630192016'),
('20140630193205'),
('20140630225343'),
('20140711151619'),
('20140714140130'),
('20140715193752'),
('20140715201115'),
('20140731114015'),
('20140814213222'),
('20140818221006'),
('20140820193417'),
('20140826145300'),
('20140829212030'),
('20140917173435'),
('20140930200457'),
('20141003155347'),
('20141010040750'),
('20141010045603'),
('20141024151713'),
('20141027184753'),
('20141118201319'),
('20141120015159'),
('20141120183556'),
('20141125211757'),
('20141125225527'),
('20141125230155'),
('20141204163935'),
('20141204171132'),
('20141208163305'),
('20141216174740'),
('20150102215927'),
('20150107201354'),
('20150107202753'),
('20150107204858'),
('20150108220636'),
('20150111220256'),
('20150111220313'),
('20150130224716'),
('20150203194323'),
('20150203194337'),
('20150210200137'),
('20150305162024'),
('20150409152145'),
('20150409153006'),
('20150409154101'),
('20150409162207'),
('20150410205627'),
('20150410213415'),
('20150414023218'),
('20150414023501'),
('20150420131548'),
('20150428131528'),
('20150503210938'),
('20150508200845'),
('20150513004314'),
('20150513214316'),
('20150518183228'),
('20150518183547'),
('20150518185411'),
('20150518185832'),
('20150522155809'),
('20150523151050'),
('20150523152338'),
('20150523221424'),
('20150602164703'),
('20150602164808'),
('20150609181413'),
('20150609220156'),
('20150619032522'),
('20150622150226'),
('20150717184324'),
('20150720200541'),
('20150723172220'),
('20150730154029'),
('20150731223735'),
('20150804163342'),
('20150814195019'),
('20150818202759'),
('20150821144231'),
('20151008193453'),
('20151020184726'),
('20151020185018'),
('20151021144605'),
('20151023145023'),
('20151106225413'),
('20151111004226'),
('20151112192400'),
('20151119181923'),
('20151125170439'),
('20151125170657'),
('20151125171138'),
('20151125173402'),
('20151125230751'),
('20151214163302'),
('20160307192607'),
('20160307232457'),
('20160316131516'),
('20160316131535'),
('20160401203518'),
('20160406212829'),
('20160425164120'),
('20160614183835'),
('20160701205927'),
('20160715201029'),
('20160824184919'),
('20160902210131'),
('20160906163853'),
('20160906165419'),
('20160920232721'),
('20161211051907'),
('20161211204922'),
('20170210193257'),
('20170217175056'),
('20170725181440'),
('20170907224737'),
('20171024201927'),
('20180124205005'),
('20180209165100'),
('20180212233524'),
('20180328223830'),
('20180329180056'),
('20180408135739'),
('20180408143507'),
('20180514234655'),
('20180608190543'),
('20180611171416'),
('20180621213347'),
('20181025225740'),
('20181109212904'),
('20181213153332'),
('20190205200912'),
('20190920181828'),
('20191113214448');


