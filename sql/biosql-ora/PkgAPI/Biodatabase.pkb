-- -*-Sql-*- mode (to keep my emacs happy)
--
-- API Package Body for Biodatabase.
--
-- Scaffold auto-generated by gen-api.pl. gen-api.pl is
-- (c) Hilmar Lapp, lapp@gnf.org, GNF, 2002.
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/Biodatabase.pkb,v 1.10 2003/06/14 02:53:05 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
--
-- You may distribute this module under the same terms as Perl.
-- Refer to the Perl Artistic License (see the license accompanying this
-- software package, or see http://www.perl.com/language/misc/Artistic.html)
-- for the terms under which you may use, modify, and redistribute this module.
-- 
-- THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
-- MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--

CREATE OR REPLACE
PACKAGE BODY DB IS

db_cached SG_BIODATABASE.OID%TYPE DEFAULT NULL;
cache_key VARCHAR2(128) DEFAULT NULL;

CURSOR DB_c (
		DB_NAME	IN SG_BIODATABASE.NAME%TYPE)
RETURN SG_BIODATABASE%ROWTYPE IS
	SELECT t.* FROM SG_BIODATABASE t
	WHERE
		t.NAME = DB_NAME
	;

CURSOR DB_Acr_c (
		DB_ACRONYM	IN SG_BIODATABASE.ACRONYM%TYPE)
RETURN SG_BIODATABASE%ROWTYPE IS
	SELECT t.* FROM SG_BIODATABASE t
	WHERE
		t.ACRONYM = DB_ACRONYM
	;

FUNCTION get_oid(
		DB_OID	IN SG_BIODATABASE.OID%TYPE DEFAULT NULL,
		DB_NAME	IN SG_BIODATABASE.NAME%TYPE,
		DB_AUTHORITY	IN SG_BIODATABASE.AUTHORITY%TYPE DEFAULT NULL,
		DB_ACRONYM	IN SG_BIODATABASE.ACRONYM%TYPE DEFAULT NULL,
		DB_URI	IN SG_BIODATABASE.URI%TYPE DEFAULT NULL,
		DB_DESCRIPTION	IN SG_BIODATABASE.DESCRIPTION%TYPE DEFAULT NULL,
		do_DML		IN NUMBER DEFAULT BSStd.DML_NO)
RETURN SG_BIODATABASE.OID%TYPE
IS
	pk	SG_BIODATABASE.OID%TYPE DEFAULT NULL;
	DB_row	DB_c%ROWTYPE;
	key_str VARCHAR2(128) DEFAULT DB_NAME || '|' || DB_ACRONYM;	
BEGIN
	-- initialize
	IF (do_DML > BSStd.DML_NO) THEN
		pk := DB_OID;
	END IF;
	-- look up
	IF pk IS NULL THEN
		IF (key_str = cache_key) THEN
		        pk := db_cached;
		ELSE
			-- reset cache
			cache_key := NULL;
			db_cached := NULL;
			-- look up primary key
			IF DB_Name IS NULL THEN
				FOR DB_row IN DB_Acr_c(DB_ACRONYM) LOOP
			    		pk := DB_row.OID;
			    		cache_key := key_str;
			    		db_cached := pk;
				END LOOP;
			ELSE
				FOR DB_row IN DB_c(DB_NAME) LOOP
			    		pk := DB_row.OID;
			    		cache_key := key_str;
			    		db_cached := pk;
				END LOOP;
			END IF;
		END IF;
	END IF;
	-- insert/update if requested
	IF (pk IS NULL) AND 
	   ((do_DML = BSStd.DML_I) OR (do_DML = BSStd.DML_UI)) THEN
	    	--
	    	-- insert the record and obtain the primary key
	    	pk := do_insert(
		        NAME => DB_NAME,
			AUTHORITY => DB_AUTHORITY,
			ACRONYM => DB_ACRONYM,
			URI => DB_URI,
			DESCRIPTION => DB_DESCRIPTION);
	ELSIF (do_DML = BSStd.DML_U) OR (do_DML = BSStd.DML_UI) THEN
	        -- update the record (note that not provided FKs will not
		-- be changed nor looked up)
		do_update(
			DB_OID	=> pk,
		        DB_NAME => DB_NAME,
			DB_AUTHORITY => DB_AUTHORITY,
			DB_ACRONYM => DB_ACRONYM,
			DB_URI => DB_URI,
			DB_DESCRIPTION => DB_DESCRIPTION);
	END IF;
	-- return the primary key
	RETURN pk;
END;

FUNCTION do_insert(
		NAME	IN SG_BIODATABASE.NAME%TYPE,
		AUTHORITY	IN SG_BIODATABASE.AUTHORITY%TYPE,
		ACRONYM	IN SG_BIODATABASE.ACRONYM%TYPE,
		URI	IN SG_BIODATABASE.URI%TYPE,
		DESCRIPTION	IN SG_BIODATABASE.DESCRIPTION%TYPE)
RETURN SG_BIODATABASE.OID%TYPE 
IS
	pk	SG_BIODATABASE.OID%TYPE;
BEGIN
	-- pre-generate the primary key value
	SELECT SG_Sequence.nextval INTO pk FROM DUAL;
	-- insert the record
	INSERT INTO SG_BIODATABASE (
		OID,
		NAME,
		AUTHORITY,
		ACRONYM,
		URI,
		DESCRIPTION)
	VALUES (pk,
		NAME,
		AUTHORITY,
		ACRONYM,
		URI,
		DESCRIPTION)
	;
	-- return the new pk value
	RETURN pk;
END;

PROCEDURE do_update(
		DB_OID	IN SG_BIODATABASE.OID%TYPE,
		DB_NAME	IN SG_BIODATABASE.NAME%TYPE,
		DB_AUTHORITY	IN SG_BIODATABASE.AUTHORITY%TYPE,
		DB_ACRONYM	IN SG_BIODATABASE.ACRONYM%TYPE,
		DB_URI	IN SG_BIODATABASE.URI%TYPE,
		DB_DESCRIPTION	IN SG_BIODATABASE.DESCRIPTION%TYPE)
IS
BEGIN
	-- update the record (and leave attributes passed as NULL untouched)
	UPDATE SG_BIODATABASE
	SET
		NAME = NVL(DB_NAME, NAME),
		AUTHORITY = NVL(DB_AUTHORITY, AUTHORITY),
		ACRONYM = NVL(DB_ACRONYM, ACRONYM),
		URI = NVL(DB_URI, URI),
		DESCRIPTION = NVL(DB_DESCRIPTION, DESCRIPTION)
	WHERE OID = DB_OID
	;
END;

END DB;
/

