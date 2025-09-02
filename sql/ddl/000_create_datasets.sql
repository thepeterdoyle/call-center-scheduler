-- PURPOSE: Create datasets (schemas) used by this project.
-- Run once per environment (dev/stg/prod). Adjust location as needed.

CREATE SCHEMA IF NOT EXISTS `ref` OPTIONS(location="US");
CREATE SCHEMA IF NOT EXISTS `ops` OPTIONS(location="US");
CREATE SCHEMA IF NOT EXISTS `util` OPTIONS(location="US");
CREATE SCHEMA IF NOT EXISTS `rpt` OPTIONS(location="US");
