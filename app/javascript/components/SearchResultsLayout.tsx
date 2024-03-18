import React from 'react';
import { createGlobalStyle } from 'styled-components';
import { darken } from 'polished';
import { I18n } from 'i18n-js';

import './SearchResultsLayout.css';

import { Header } from './Header';
import { Facets } from './Facets/Facets';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';
import { Footer } from './Footer/Footer';
import { Identifier } from './Identifier/Identifier';
import { LanguageContext } from '../contexts/LanguageContext';
import { StyleContext, styles } from '../contexts/StyleContext';

export interface NavigationLink {
  active: boolean; label: string; url: string, facet: string;
}

export interface PageData {
  affiliate: string;
  displayLogoOnly: boolean;
  title: string;
  logo: {
    url: string;
    text: string;
  };
  homepageUrl: string;
}

export interface Language {
  code: string;
  rtl: boolean;
}

export interface FontsAndColors {
  activeSearchTabNavigationColor: string;
  bannerBackgroundColor: string;
  bannerTextColor: string;
  bestBetBackgroundColor: string;
  buttonBackgroundColor: string;
  footerAndResultsFontFamily: string;
  footerBackgroundColor: string;
  footerLinksTextColor: string;
  headerBackgroundColor: string;
  headerLinksFontFamily: string;
  headerNavigationBackgroundColor: string;
  headerPrimaryLinkColor: string;
  headerSecondaryLinkColor: string;
  headerTextColor: string;
  healthBenefitsHeaderBackgroundColor: string;
  identifierBackgroundColor: string;
  identifierFontFamily: string;
  identifierHeadingColor: string;
  identifierLinkColor: string;
  pageBackgroundColor: string;
  primaryNavigationFontFamily: string;
  primaryNavigationFontWeight: string;
  resultDescriptionColor: string;
  resultTitleColor: string;
  resultTitleLinkVisitedColor: string;
  resultUrlColor: string;
  searchTabNavigationLinkColor: string;
  sectionTitleColor: string;
}

interface SearchResultsLayoutProps {
  page: PageData;
  resultsData?: {
    total?: number;
    totalPages: number;
    unboundedResults: boolean;
    results: {
      title: string;
      url: string;
      description: string;
      updatedDate?: string;
      publishedDate?: string;
      thumbnailUrl?: string;
      fileType?: string,
      youtube?: boolean;
      youtubePublishedAt?: string;
      youtubeThumbnailUrl?: string;
      youtubeDuration?: string;
      blendedModule?: string;
    }[] | null;
  } | null;
  additionalResults?: {
    recommendedBy: string;
    newNews?: {
      title: string,
      link: string,
      description: string,
      publishedAt: string
    }[];
    oldNews?: {
      title: string,
      link: string,
      description: string,
      publishedAt: string
    }[];
    textBestBets?: {
      title: string;
      url: string;
      description: string;
    }[];
    graphicsBestBet?: {
      title: string;
      titleUrl?: string;
      imageUrl?: string;
      imageAltText?: string;
      links?: {
        title: string;
        url: string;
      }[];
    };
    jobs?: {
      positionTitle: string;
      positionUri: string;
      positionLocation: string;
      organizationName: string;
      minimumPay: number;
      maximumPay: number;
      rateIntervalCode: string;
      applicationCloseDate: string;
    }[];
    youtubeNewsItems?: {
      link: string;
      title: string;
      description: string;
      publishedAt: string;
      youtubeThumbnailUrl: string;
      duration: string;
    }[];
    federalRegisterDocuments?: {
      commentsCloseOn: string | null;
      contributingAgencyNames: string[];
      documentNumber: string;
      documentType: string;
      endPage: number;
      htmlUrl: string;
      pageLength: number;
      publicationDate: string;
      startPage: number;
      title: string;
    }[];
    healthTopic?: {
      title: string;
      description: string;
      url: string;
      studiesAndTrials?: {
        title: string;
        url: string;
      }[];
      relatedTopics?: {
        title: string;
        url: string;
      }[];
    };
  } | null;
  vertical: string;
  params?: {
    query?: string
  };
  translations: {
    en?: { noResultsForAndTry: string }
  };
  language?: Language;
  relatedSites?: {
    label: string;
    link: string;
  }[];
  alert?: {
    title: string;
    text: string;
  };
  spellingSuggestion?: {
    suggested: string;
    original: string;
  };
  sitelimit?: {
    sitelimit: string;
    url: string;
  };
  navigationLinks: NavigationLink[];
  extendedHeader: boolean;
  fontsAndColors: FontsAndColors;
  footerLinks?: {
    title: string,
    url: string
  }[];
  primaryHeaderLinks?: {
    title: string,
    url: string
  }[];
  secondaryHeaderLinks?: {
    title: string,
    url: string
  }[];
  identifierContent?: {
    domainName: string | null;
    parentAgencyName: string | null;
    parentAgencyLink: string | null;
    logoUrl: string | null;
    logoAltText: string | null;
  };
  identifierLinks?: {
    title: string,
    url: string
  }[] | null;
  relatedSearches?: { label: string; link: string; }[];
  newsLabel?: {
    newsAboutQuery: string;
    results: {
      title: string;
      feedName: string,
      publishedAt: string
    }[] | null;
  } | null;
  relatedSitesDropdownLabel?: string;
  agencyName?: string;
  jobsEnabled?: boolean;
  noResultsMessage?: {
    text?: string;
    urls?: {
      title: string;
      url: string;
    }[];
  };
}

const GlobalStyle = createGlobalStyle<{ styles: { pageBackgroundColor: string; buttonBackgroundColor: string; } }>`
  .serp-result-wrapper {
    background-color: ${(props) => props.styles.pageBackgroundColor};
  }
  .usa-button {
    background-color: ${(props) => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${(props) => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }
`;

const isBasicHeader = (extendedHeader: boolean): boolean => {
  return !extendedHeader;
};

const videosUrl = (links: NavigationLink[]) => links.find((link) => link.facet === 'YouTube')?.url ;

const SearchResultsLayout = ({ page, resultsData, additionalResults, vertical, params = {}, translations, language = { code: 'en', rtl: false }, relatedSites = [], extendedHeader, footerLinks, primaryHeaderLinks, secondaryHeaderLinks, fontsAndColors, newsLabel, identifierContent, identifierLinks, navigationLinks, relatedSitesDropdownLabel = '', alert, spellingSuggestion, relatedSearches, sitelimit, noResultsMessage, jobsEnabled, agencyName }: SearchResultsLayoutProps) => {
  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = language.code;

  const additionalResults2 = {
      recommendedBy: "NIH",
      graphicsBestBet: {
        title: "<strong>Clinical</strong> <strong>Trials</strong>",
        titleUrl: null,
        imageUrl: "https://d3qcdigd1fhos0.cloudfront.net/production/featured_collection/792/image/1469030772/medium/clinicaltrialsandyou20160720-6201-fflfuo.jpg?1469030772",
        imageAltText: "What You Don’t Know Could Help You",
        links: [{
            title: "Understanding Medical Research",
            url: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html"
          },
          {
            title: "Understanding Medical Research",
            url: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html"
          },
          {
            title: "Understanding Medical Research",
            url: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html"
          }
        ]
      },
      textBestBets: [{
    title: "textBestBets title 1",
    url: "https://gsa.gov",
    description: "this is test desc"
  }, {
    title: "textBestBets title 2",
    url: "https://gsa.gov",
    description: "this is test desc"
      }],
      // healthTopic: {
      //   title: "Clinical Trials",
      //   description: "Clinical trials are research studies that test how well new medical approaches work in people.",
      //   url: "https://medlineplus.gov/clinicaltrials.html",
      //   relatedTopics: [{
      //     title: "Understanding Medical Research",
      //     url: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html"
      //   }],
      //   studiesAndTrials: [{
      //     title: "Understanding Medical Research",
      //     url: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html"
      //   }]
      // },
      youtubeNewsItems: [{
          link: "https://www.youtube.com/watch?v=5e_mKnWL77M",
          title: "Build Better <strong>Clinical</strong> <strong>Trial</strong> Outreach Materials Using OutreachPro",
          description: "The National Institute on Aging launched a free online tool to help increase participation in clinical trials for Alzheimer's disease and related dementias, with a focus on traditionally underrepresented populations. OutreachPro enables researchers to create and customize ...",
          publishedAt: "December 19, 2023 18:00",
          youtubeThumbnailUrl: "https://i.ytimg.com/vi/5e_mKnWL77M/default.jpg",
          duration: "1:41"
        },
        {
          link: "https://www.youtube.com/watch?v=5e_mKnWL77M",
          title: "Build Better <strong>Clinical</strong> <strong>Trial</strong> Outreach Materials Using OutreachPro",
          description: "The National Institute on Aging launched a free online tool to help increase participation in clinical trials for Alzheimer's disease and related dementias, with a focus on traditionally underrepresented populations. OutreachPro enables researchers to create and customize ...",
          publishedAt: "December 19, 2023 18:00",
          youtubeThumbnailUrl: "https://i.ytimg.com/vi/5e_mKnWL77M/default.jpg",
          duration: "1:41"
        }
      ],
      newNews: [{
          title: "BRAIN Initiative: Production and distribution facilities for brain cell type-specific access reagents (U24 <strong>Clinical</strong> <strong>Trial</strong> Not Allowed)",
          description: "Funding Opportunity RFA-MH-25-105 from the NIH Guide for Grants and Contracts. This BRAIN Initiative Notice of Funding Opportunity (NOFO) is to support scaled reagent production and distribution facilities involving technologies to access brain cell types. Facilities for production and distribution of these reagents by a broad and diverse set of neuroscientists will be encouraged. This NOFO is part of the BRAIN Initiative Armamentarium for Brain Cell Access transformative project. Efforts will b...",
          link: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html",
          publishedAt: "2024-02-20"
        },
        {
          title: "Notice of Intent to Publish a Funding Opportunity Announcement for Cell and Gene Therapies for HIV Cure: Developing a Pipeline (P01 <strong>Clinical</strong> <strong>Trial</strong> Not Allowed)",
          description: "Notice NOT-AI-24-015 from the NIH Guide for Grants and Contracts",
          link: "http://grants.nih.gov/grants/guide/notice-files/NOT-AI-24-015.html",
          publishedAt: "2024-02-06"
        },
        {
          title: "Notice of Clarification of NIMH Research Priorities for PAR-24-077 \"Addressing Health and Health Care Disparities among Sexual and Gender Minority Populations (R01 - <strong>Clinical</strong> <strong>Trials</strong> Optional)",
          description: "Notice NOT-MH-24-170 from the NIH Guide for Grants and Contracts",
          link: "http://grants.nih.gov/grants/guide/notice-files/NOT-MH-24-170.html",
          publishedAt: "2024-02-05"
        }
      ],
      oldNews: [{
          title: "BRAIN Initiative: Production and distribution facilities for brain cell type-specific access reagents (U24 <strong>Clinical</strong> <strong>Trial</strong> Not Allowed)",
          description: "Funding Opportunity RFA-MH-25-105 from the NIH Guide for Grants and Contracts. This BRAIN Initiative Notice of Funding Opportunity (NOFO) is to support scaled reagent production and distribution facilities involving technologies to access brain cell types. Facilities for production and distribution of these reagents by a broad and diverse set of neuroscientists will be encouraged. This NOFO is part of the BRAIN Initiative Armamentarium for Brain Cell Access transformative project. Efforts will b...",
          link: "http://grants.nih.gov/grants/guide/rfa-files/RFA-MH-25-105.html",
          publishedAt: "2024-02-20"
        },
        {
          title: "Notice of Intent to Publish a Funding Opportunity Announcement for Cell and Gene Therapies for HIV Cure: Developing a Pipeline (P01 <strong>Clinical</strong> <strong>Trial</strong> Not Allowed)",
          description: "Notice NOT-AI-24-015 from the NIH Guide for Grants and Contracts",
          link: "http://grants.nih.gov/grants/guide/notice-files/NOT-AI-24-015.html",
          publishedAt: "2024-02-06"
        },
        {
          title: "Notice of Clarification of NIMH Research Priorities for PAR-24-077 \"Addressing Health and Health Care Disparities among Sexual and Gender Minority Populations (R01 - <strong>Clinical</strong> <strong>Trials</strong> Optional)",
          description: "Notice NOT-MH-24-170 from the NIH Guide for Grants and Contracts",
          link: "http://grants.nih.gov/grants/guide/notice-files/NOT-MH-24-170.html",
          publishedAt: "2024-02-05"
        }
      ],
      jobs: [{
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        },
        {
          positionTitle: "positionTitle",
          positionUri: "https://gsa.gov",
          positionLocation: "DC",
          organizationName: "GSA",
          minimumPay: 120000,
          maximumPay: 150000,
          rateIntervalCode: "PA",
          applicationCloseDate: "July 10, 2024"
        }
      ],
      federalRegisterDocuments: [{
          commentsCloseOn: "Jan 10, 2020",
          contributingAgencyNames: ["GSA"],
          documentNumber: "12",
          documentType: "Text",
          endPage: 20,
          htmlUrl: "https://gsa.gov",
          pageLength: 5,
          publicationDate: "Jan 20, 2020",
          startPage: 7,
          title: "this is title 1"
        },
        {
          commentsCloseOn: "Jan 10, 2021",
          contributingAgencyNames: ["GSA"],
          documentNumber: "12",
          documentType: "PDF",
          endPage: 20,
          htmlUrl: "https://gsa.gov",
          pageLength: 5,
          publicationDate: "Jan 20, 2020",
          startPage: 7,
          title: "this is title 2"
        },
        {
          commentsCloseOn: "Jan 10, 2022",
          contributingAgencyNames: ["GSA"],
          documentNumber: "12",
          documentType: "PDF",
          endPage: 20,
          htmlUrl: "https://gsa.gov",
          pageLength: 5,
          publicationDate: "Jan 20, 2020",
          startPage: 7,
          title: "this is title 3"
        },
        {
          commentsCloseOn: "Jan 10, 2024",
          contributingAgencyNames: ["GSA"],
          documentNumber: "12",
          documentType: "Excel",
          endPage: 20,
          htmlUrl: "https://gsa.gov",
          pageLength: 5,
          publicationDate: "Jan 20, 2020",
          startPage: 7,
          title: "this is title 4"
        }
      ],
      healthTopic: {
        title: "this is title",
        description: "this is description",
        url: "https://gsa.gov",
        studiesAndTrials: [{
            title: "title 1",
            url: "https://gsa.gov"
          },
          {
            title: "title 2",
            url: "https://gsa.gov"
          }
        ],
        relatedTopics: [{
            title: "title 1",
            url: "https://gsa.gov",
          },
          {
            title: "title 2",
            url: "https://gsa.gov",
          }
          ]
        }
  };
  const jobsEnabled2 = true;
  const relatedSearches2 = [{
    label: "label",
    link: "https://gsa.gob"
  }, {
    label: "label",
    link: "https://gsa.gob"
  }];

  return (
    <LanguageContext.Provider value={i18n}>
      <StyleContext.Provider value={ fontsAndColors ? fontsAndColors : styles }>
        <StyleContext.Consumer>
          {(value) => <GlobalStyle styles={value} />}
        </StyleContext.Consumer>
        <Header 
          page={page}
          isBasic={isBasicHeader(extendedHeader)}
          primaryHeaderLinks={primaryHeaderLinks}
          secondaryHeaderLinks={secondaryHeaderLinks}
        />
      
        <div className="usa-section serp-result-wrapper">
          <Facets />
  
          <SearchBar query={params.query} relatedSites={relatedSites} navigationLinks={navigationLinks} relatedSitesDropdownLabel={relatedSitesDropdownLabel} alert={alert}/>

          {/* This ternary is needed to handle the case when Bing pagination leads to a page with no results */}
          {resultsData ? (
            // <Results 
            //     page={page}
            //     results={resultsData.results}
            //     vertical={vertical}
            //     totalPages={resultsData.totalPages}
            //     total={resultsData.total}
            //     query={params.query}
            //     unboundedResults={resultsData.unboundedResults}
            //     additionalResults={additionalResults2}
            //     newsAboutQuery={newsLabel?.newsAboutQuery}
            //     spellingSuggestion={spellingSuggestion}
            //     videosUrl= {videosUrl(navigationLinks)}
            //     relatedSearches = {relatedSearches2}
            //     noResultsMessage = {noResultsMessage}
            //     sitelimit={sitelimit}
            //     jobsEnabled={jobsEnabled2}
            //     agencyName={agencyName}
            // />
            <Results
              page={page}
              results={resultsData.results}
              vertical={vertical}
              totalPages={resultsData.totalPages}
              total={resultsData.total}
              query={params.query}
              unboundedResults={resultsData.unboundedResults}
              additionalResults={additionalResults}
              newsAboutQuery={newsLabel?.newsAboutQuery}
              spellingSuggestion={spellingSuggestion}
              videosUrl= {videosUrl(navigationLinks)}
              relatedSearches = {relatedSearches}
              noResultsMessage = {noResultsMessage}
              sitelimit={sitelimit}
              jobsEnabled={jobsEnabled}
              agencyName={agencyName}
            />
            ) : params.query ? (
            <Results
              page={page}
              vertical={vertical}
              totalPages={null}
              query={params.query}
              unboundedResults={true}
              noResultsMessage = {noResultsMessage}
            />) : <></>}
        </div>

        <Footer 
          footerLinks={footerLinks}
        />
        <Identifier
          identifierContent={identifierContent}
          identifierLinks={identifierLinks}
        />
      </StyleContext.Provider>
    </LanguageContext.Provider>
  );
};

export default SearchResultsLayout;
