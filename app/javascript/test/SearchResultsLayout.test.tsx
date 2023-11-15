import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import SearchResultsLayout, { NavigationLink } from '../components/SearchResultsLayout';

const translations = {
  en: {
    noResultsForAndTry: 'Sorry, no results found for \'%{query}\'. Try entering fewer or more general search terms.',
    recommended: 'Recommended',
    searches: { by: 'by' }
  }
};

const fontsAndColors = {
  headerLinksFontFamily: '"Georgia", "Cambria", "Times New Roman", "Times", serif'
};

const newsLabel = {
  newsAboutQuery: 'News about GSA',
  results: [{
    title: 'title 1',
    feedName: 'feedName 1',
    publishedAt: '22 days ago'
  }]
};

const navigationLinks: NavigationLink[] = [];

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('SearchResultsLayout', () => {
  const page = {
    title: 'Search.gov',
    logoUrl: 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg'
  };

  it('renders the correct header type and content', () => {
    render(<SearchResultsLayout page={page} params={{}} resultsData={{ results: [], totalPages: 1, unboundedResults: false }} vertical='web' translations={translations} extendedHeader={false} fontsAndColors={fontsAndColors} navigationLinks={navigationLinks} />);
    const [header] = screen.getAllByTestId('header');
    expect(header).toHaveClass('usa-header--basic');
  });

  it('renders search results', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 20; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} />);
    const resultTitle = screen.getAllByText(/test result 1/i);
    const resultUrl = screen.getAllByText(/www.search.gov/i);
    const resultBody = screen.getAllByText(/result body/i);
    const publishedDate = screen.getAllByText(/May 9th, 2023/i);
    const updatedDate = screen.getAllByText(/Updated on May 10th, 2023/i);
    expect(resultTitle).toHaveLength(20);
    expect(resultUrl).toHaveLength(20);
    expect(resultBody).toHaveLength(20);
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
    render(<SearchResultsLayout page={page} params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} />);
    const bestBetRecommendedBy = screen.getByText(/Recommended by USAgov/i);
    const bestBetTitle = screen.getByText(/A best bet/i);
    const bestBetDescription = screen.getByText(/This is the best bet/i);
    const bestBetUrl = screen.getByText(/www.example.com/i);
    expect(bestBetRecommendedBy).toBeInTheDocument();
    expect(bestBetTitle).toBeInTheDocument();
    expect(bestBetDescription).toBeInTheDocument();
    expect(bestBetUrl).toBeInTheDocument();
  });

  it('renders graphics best bets', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 2; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const additionalResults = { recommendedBy: 'USAgov', textBestBets: [], graphicsBestBet: { title: 'Search support', titleUrl: 'https://search.gov/support.html', imageUrl: 'https://search.gov/support.jpg', imageAltText: 'support alt text', links: [{ title: 'Learning', url: 'https://search.gov/learn' }] } };
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout page={page} params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} />);
    const bestBetRecommendedBy = screen.getByText(/Recommended by USAgov/i);
    const bestBetTitle = screen.getByText(/Search support/i);
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    const bestBetLink = screen.getByText(/Learning/i);
    expect(bestBetRecommendedBy).toBeInTheDocument();
    expect(bestBetTitle).toBeInTheDocument();
    expect(bestBetLink).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://search.gov/support.jpg');
    expect(img).toHaveAttribute('alt', 'support alt text');
  });

  it('renders image search results', () => {
    const resultsData = { totalPages: 2, unboundedResults: true, results: [{ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', thumbnailUrl: 'https://www.search.gov/test_image.png', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' }] };
    render(<SearchResultsLayout page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='image' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
    expect(img).toHaveAttribute('alt', 'test result 1');
  });

  it('renders image page results', () => {
    const resultsData = { totalPages: 2, unboundedResults: true, results: [{ altText: 'Heritage Tourism | GSA', url: 'https://18f.gsa.gov/2015/06/22/avoiding-cloudfall/', thumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60', image: true, title: 'test result 1', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' }] };
    render(<SearchResultsLayout page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='image' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} />);
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'Heritage Tourism | GSA');
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
    render(<SearchResultsLayout page={page} params={{ query: 'foo' }} resultsData={resultsData} vertical='image' translations={translations} extendedHeader={true} fontsAndColors={fontsAndColors} newsLabel={newsLabel} navigationLinks={navigationLinks} />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
    expect(img).toHaveAttribute('alt', 'test result 1');
  });
});
