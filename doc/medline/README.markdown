# USASearch Medline XML

## XML Format 

Info for developers on Medline XML data at <http://www.nlm.nih.gov/medlineplus/xml.html>

The XML vocab file is updated every saturday and currently (as of 2011-04-26) 
contains 1750 topics with references to 44 topic groups.  Group information is 
available from a separate XML file but is also contained in the vocab itself.

The summary XML ( /MedicalTopics/MedicalTopic[*]/FullSummary ) 
is an HTML subset encoded as a text string using p/ul/li/a/em tags and obeys 
the following constraints (modulo exceptions as noted).  

    - all summary text (incl entity references and text within em and a tags) is 
      contained within p or ul/li constructs (there are about half a dozen exeptions
      which are probably unintended))
    - the only links found are to medline plus internal URLs with the majority of
      summaries containing at least one hyperlink
    - most summary texts end with an attribution (eg CDC) which is contained in 
      a p tag with a style attribute (one exception which uses class=attribution)
    - summary text are between 80 and 1800 characters long (including attributions)
      with sizes distributed along a nice symmetric bell curve around an average
      of approx 850 characters

The XML is encoded as UTF8 meaning that the summaries, while having their angular 
brackets escaped, are not really separately encoded within the XML but rather 
nested as an XHTML-ish subset.  This means that we have to pick an encoding 
and convention for use of entity references when saving that HTML to the db.

Nokogiri's default behaviour is to encode things like mexican umlauts and funny  
quotes as entity references.  


Other exceptions:

    - two of them (eg: Medication Errors) contain nested ul constructs
    - about 20 of them are english-only topics; there are no spanish-only topics


## Tasks

### rake usasearch:medline:lint DATE=<date>

Will show any anomalies found in the data set including the summary XML.  Will 
give some stats and a list of single-locale topics.


### rake usasearch:medline:diff FROM_DATE=<date> TO_DATE=<date>

Will show how much has changed between two different data sets.  If you do not 
specify a FROM_DATE, it will use the current (db) data.  If you do not specify 
a TO_DATE, it will use the most recent available data set.


### rake usasearch:medline:load DATE=<date>

Will load a new data set into the DB by adding/deleting/modifying medline 
topics and groups in the db where necessary.  


## Utilities

Included under doc/medline are three utilities

### fetchmedline

grabs the latest medline vocab xml and runs through it to look for 

    - some general statistics
    - summary text format
    - summary text sizes

and dumps the info to stdout.  Also creates a JSON file with a few dozen 
text summaries, choosing thos with unique structures.

### closure

grabs the latest vocab XML (if necessary) and, given a list of topic IDs, 
modifies the XML data to remove any references to topics not on the list
of desired topics.

the resulting self-contained XML subset is written to disk as *_closure.xml.


### lmclosure

grabs the latest vocab XML (if necessary) and, given a list of topic IDs, 
adds to this list any topics related to these topics via the "language_mapped_topic_id"
field.

the resulting expanded list of topic ids is printed to stdout.


### meshs

grabs the latest vocab XML (if necessary) and looks at the MeshHeading relationships.
It creates a histogram showing how many topics have how many mesh heading references.
It also shows which topic have no seeref meshheadings, no meshheadins, or neither type.

