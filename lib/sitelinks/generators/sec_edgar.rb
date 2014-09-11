require 'uri/common'

module Sitelinks
  module Generators
    class SecEdgar
      include Sitelinks::Generators

      self.url_prefix = 'www.sec.gov/Archives/edgar/data/'.freeze
      MATCHING_URL_REGEX = %r[^(?!.*-index\.htm$)https?://(www\.)?sec\.gov/Archives/edgar/data/\d+/\d+\/.+$]i

      DEFAULT_BROWSE_EDGAR_PARAMS = { Find: 'Search',
                                      action: 'getcompany',
                                      owner: 'exclude'
      }.freeze

      def self.generate(url)
        return [] unless url =~ MATCHING_URL_REGEX

        path_as_array = URI.parse(url).path.split('/')
        return [] unless path_as_array.length == 7

        [generate_full_filing_url(path_as_array),
         generate_browse_edgar_url(path_as_array)]
      end

      def self.generate_browse_edgar_url(path_as_array)
        cik = path_as_array[4]
        browse_edgar_params = DEFAULT_BROWSE_EDGAR_PARAMS.merge(CIK: cik)

        { title: 'Most Recent Filings for this Company',
          url: "http://www.sec.gov/cgi-bin/browse-edgar?#{browse_edgar_params.to_param}" }
      end

      def self.generate_full_filing_url(path_as_array)
        cik = path_as_array[4]
        cik_part_1 = path_as_array[5].slice(0, 10)
        cik_part_2 = path_as_array[5].slice(10, 2)
        cik_part_3 = path_as_array[5].slice(12..-1)

        # url = "http://www.sec.gov/Archives/edgar/data/#{cik}/#{cik_part_1}-#{cik_part_2}-#{cik_part_3}-index.htm"

        full_filing_path = "#{cik}/#{cik_part_1}-#{cik_part_2}-#{cik_part_3}-index.htm"
        url = "http://www.sec.gov/Archives/edgar/data/#{full_filing_path}"

        { title: 'Full Filing', url: url }
      end
    end
  end
end

# original script from SEC
# <script type="text/javascript">
# var numResults = document.getElementsByTagName("h4").length;
# for (i=0; i < numResults; i++) {
#     var resultNum = "result-" + (i + 1);
# var searchDiv = document.getElementById(resultNum);
# var links = searchDiv.getElementsByTagName("a");
# var docLinks = links[0].getAttribute("href");
# var linkArray = docLinks.split("/");
#     if (linkArray[3] === "Archives") {
# var cikHref = "http://www.sec.gov/cgi-bin/browse-edgar?CIK=" + linkArray[6] + "&Find=Search&owner=exclude&action=getcompany";
# var cikSlice1 = linkArray[7].slice(0,10);
# var cikSlice2 = linkArray[7].slice(10,12);
# var cikSlice3 = linkArray[7].slice(12);
# var fullFilingHref = "http://www.sec.gov/Archives/edgar/data/" + linkArray[6] + "/" + cikSlice1 + "-" + cikSlice2 + "-" + cikSlice3 + "-index.htm";
# var edgarLinksText = "[<a href='" + fullFilingHref +"'>Full Filing</a> | <a href='" + cikHref + "'>Most Recent Filings for this Company</a>]";
# var cikLinks = document.createElement("p");
# var cikLinksText = document.createTextNode("");
# cikLinks.appendChild(cikLinksText);
# cikLinks.innerHTML = edgarLinksText;
# cikLinks.className = "description";
# cikLinks.setAttribute("style", "margin-top: 3px;");
# searchDiv.appendChild(cikLinks);
#     }
#     else {
#         continue;
#     }
# }
# </script>
