import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import SearchResultsLayout, { NavigationLink } from '../components/SearchResultsLayout';
import renderer from 'react-test-renderer';
import 'jest-styled-components';

const fontsAndColors = {
  activeSearchTabNavigationColor: '#1f1748',
  bannerBackgroundColor: '#643617',
  bannerTextColor: '#dacb1b',
  bestBetBackgroundColor: '#6e09bf',
  buttonBackgroundColor: '#cfcd03',
  footerAndResultsFontFamily: '"Helvetica Neue", "Helvetica", "Roboto", "Arial", sans-serif',
  footerBackgroundColor: '#5fcfc5',
  footerLinksTextColor: '#46f966',
  headerBackgroundColor: '#4a402b',
  headerLinksFontFamily: '"Georgia", "Cambria", "Times New Roman", "Times", serif',
  headerNavigationBackgroundColor: '#83df0a',
  headerPrimaryLinkColor: '#594973',
  headerSecondaryLinkColor: '#c8155d',
  headerTextColor: '#C000FE',
  healthBenefitsHeaderBackgroundColor: '#abb178',
  identifierBackgroundColor: '#be1c21',
  identifierFontFamily: '"Public Sans Web"',
  identifierHeadingColor: '#f48a4c',
  identifierLinkColor: '#5d5a6f',
  pageBackgroundColor: '#761816',
  primaryNavigationFontFamily: '"Public Sans Web"',
  primaryNavigationFontWeight: 'bold',
  resultDescriptionColor: '#2bd4c7',
  resultTitleColor: '#33f0aa',
  resultTitleLinkVisitedColor: '#4a97ad',
  resultUrlColor: '#475830',
  searchTabNavigationLinkColor: '#aea9f7',
  sectionTitleColor: '#8b4a35'
};

const translations = {
  en: {
    noResultsForAndTry: 'Sorry, no results found for \'%{query}\'. Try entering fewer or more general search terms.',
    recommended: 'Recommended',
    searches: { by: 'by' }
  }
};

const newsLabel = {
  newsAboutQuery: 'News about GSA',
  results: [{
    title: 'title 1',
    feedName: 'feedName 1',
    publishedAt: '22 days ago'
  }]
};

const affiliate = {
  id: 1,
  name: 'stvn'
}

const navigationLinks: NavigationLink[] = [];

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

// Needed to access GlobalStyle elements.
// See: https://github.com/styled-components/styled-components/issues/3570#issuecomment-1537564119
jest.mock('styled-components', () =>
  jest.requireActual('styled-components/dist/styled-components.browser.cjs.js')
);

describe('SearchResultsLayout', () => {
  const page = {
    affiliate: 'searchgov',
    displayLogoOnly: false,
    title: 'Search.gov',
    logo: {
      url: 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg',
      text: 'Search.gov'
    },
    homepageUrl: 'https://search.gov',
    showVoteOrgLink: false
  };

  it('renders the correct header type and content', () => {
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{}} resultsData={{ results: [], totalPages: 1, unboundedResults: false }} vertical='web' translations={translations} extendedHeader={false} fontsAndColors={fontsAndColors} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const [header] = screen.getAllByTestId('header');
    expect(header).toHaveClass('usa-header--basic');
  });

  it('renders search results', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 20; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', fileType: 'PDF', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const resultTitle = screen.getAllByText(/test result 1/i);
    const resultUrl = screen.getAllByText(/www.search.gov/i);
    const resultBody = screen.getAllByText(/result body/i);
    const publishedDate = screen.getAllByText(/May 9th, 2023/i);
    const updatedDate = screen.getAllByText(/Updated on May 10th, 2023/i);
    const fileType = screen.getAllByText(/PDF/i);
    expect(resultTitle).toHaveLength(20);
    expect(resultUrl).toHaveLength(20);
    expect(resultBody).toHaveLength(20);
    expect(publishedDate).toHaveLength(20);
    expect(updatedDate).toHaveLength(20);
    expect(fileType).toHaveLength(20);
  });

  it('renders search results with no description and no file type', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 20; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const resultTitle = screen.getAllByText(/test result 1/i);
    const resultUrl = screen.getAllByText(/www.search.gov/i);
    const publishedDate = screen.getAllByText(/May 9th, 2023/i);
    const updatedDate = screen.getAllByText(/Updated on May 10th, 2023/i);
    expect(resultTitle).toHaveLength(20);
    expect(resultUrl).toHaveLength(20);
    expect(publishedDate).toHaveLength(20);
    expect(updatedDate).toHaveLength(20);
  });

  it('renders text best bets', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 2; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const additionalResults = { recommendedBy: 'USAgov', textBestBets: [{ title: 'A best bet', description: 'This is the best bet', url: 'http://www.example.com' }] };
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const bestBetRecommendedBy = screen.getByText(/Recommended by USAgov/i);
    const bestBetTitle = screen.getByText(/A best bet/i);
    const bestBetDescription = screen.getByText(/This is the best bet/i);
    const bestBetUrl = screen.getByText(/www.example.com/i);
    expect(bestBetRecommendedBy).toBeInTheDocument();
    expect(bestBetTitle).toBeInTheDocument();
    expect(bestBetDescription).toBeInTheDocument();
    expect(bestBetUrl).toBeInTheDocument();
  });

  it('renders graphics best bets when there is one link in the best bet', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 2; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const additionalResults = { recommendedBy: 'USAgov', textBestBets: [], graphicsBestBet: { title: 'Search support', titleUrl: 'https://search.gov/support.html', imageUrl: 'https://search.gov/support.jpg', imageAltText: 'support alt text', links: [{ title: 'Learning', url: 'https://search.gov/learn' }] } };
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const bestBetRecommendedBy = screen.getByText(/Recommended by USAgov/i);
    const bestBetTitle = screen.getByText(/Search support/i);
    const bestBetLink = screen.getByText(/Learning/i);
    expect(bestBetRecommendedBy).toBeInTheDocument();
    expect(bestBetTitle).toBeInTheDocument();
    expect(bestBetLink).toBeInTheDocument();
  });

  it('renders graphics best bets when there are more than two links in the best bet', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 2; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const additionalResults = { recommendedBy: 'USAgov', textBestBets: [], graphicsBestBet: { title: 'Search support', titleUrl: 'https://search.gov/support.html', imageUrl: 'https://search.gov/support.jpg', imageAltText: 'support alt text', links: [{ title: 'Learning', url: 'https://search.gov/learn' }, { title: 'The homepage', url: 'https://search.gov' }, { title: 'Another link', url: 'https://www.google.com' }] } };
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const bestBetRecommendedBy = screen.getByText(/Recommended by USAgov/i);
    const bestBetTitle = screen.getByText(/Search support/i);
    const bestBetLink1 = screen.getByText(/Learning/i);
    const bestBetLink2 = screen.getByText(/The homepage/i);
    const bestBetLink3 = screen.getByText(/Another link/i);
    expect(bestBetRecommendedBy).toBeInTheDocument();
    expect(bestBetTitle).toBeInTheDocument();
    expect(bestBetLink1).toBeInTheDocument();
    expect(bestBetLink2).toBeInTheDocument();
    expect(bestBetLink3).toBeInTheDocument();
  });

  it('renders image search results', () => {
    const resultsData = { totalPages: 2, unboundedResults: true, results: [{ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', thumbnailUrl: 'https://www.search.gov/test_image.png', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' }] };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='image' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const resultTitle = screen.getByText(/test result 1/i);
    expect(resultTitle).toBeInTheDocument();
  });

  it('renders image page results', () => {
    const resultsData = { totalPages: 2, unboundedResults: true, results: [{ altText: 'Heritage Tourism | GSA', url: 'https://18f.gsa.gov/2015/06/22/avoiding-cloudfall/', thumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60', image: true, title: 'test result 1', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' }] };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='image' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
  });

  it('renders videos', () => {
    const videos = [{
      title: 'test result 1',
      url: 'https://www.youtube.com/watch?v=UcaloWLCe3w',
      description: 'result body',
      publishedAt: '9 days',
      youtube: true,
      youtubePublishedAt: '2023-10-23T15:11:13.000Z',
      youtubeThumbnailUrl: 'https://www.search.gov/test_image.png',
      youtubeDuration: '0:55'
    }];
    const resultsData = { totalPages: 2, unboundedResults: true, results: videos };
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='image' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const resultTitle = screen.getByText(/test result 1/i);
    expect(resultTitle).toBeInTheDocument();
  });

  it('renders basic header styles properly', () => {
    renderer.create(<SearchResultsLayout affiliate={affiliate} page={page} params={{}} resultsData={{ results: [], totalPages: 1, unboundedResults: false }} vertical='web' translations={translations} extendedHeader={false} fontsAndColors={fontsAndColors} navigationLinks={navigationLinks} facetsEnabled={false} />).toJSON();
    expect(document.head).toMatchSnapshot();
  });

  it('renders extended header styles properly', () => {
    renderer.create(<SearchResultsLayout affiliate={affiliate} page={page} params={{}} resultsData={{ results: [], totalPages: 1, unboundedResults: false }} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} navigationLinks={navigationLinks} facetsEnabled={false} />).toJSON();
    expect(document.head).toMatchSnapshot();
  });

  it('renders search with results styles properly', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 20; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const resultsData = { totalPages: 2, unboundedResults: true, results };

    renderer.create(<SearchResultsLayout affiliate={affiliate} page={page} params={{}} resultsData={resultsData} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} navigationLinks={navigationLinks} facetsEnabled={false} />).toJSON();
    expect(document.head).toMatchSnapshot();
  });
});

describe('Tablet & Mobile view: SearchResultsLayout with facets', () => {
  beforeAll(() => {
    window.innerWidth = 400;
  });

  const page = {
    affiliate: 'searchgov',
    displayLogoOnly: false,
    title: 'Search.gov',
    logo: {
      url: 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg',
      text: 'Search.gov'
    },
    homepageUrl: 'https://search.gov',
    showVoteOrgLink: false
  };

  it('renders the facets', () => {
    render(<SearchResultsLayout affiliate={affiliate} page={page} params={{}} resultsData={{ results: [], totalPages: 1, unboundedResults: false }} vertical='web' translations={translations} extendedHeader={false} fontsAndColors={fontsAndColors} navigationLinks={navigationLinks} facetsEnabled={false} />);
    const filterLabel = screen.queryByText(/Filter search/i);
    // Below to be updated once facets backend is ready
    expect(filterLabel).not.toBeInTheDocument();
  });
});
