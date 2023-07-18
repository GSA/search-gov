import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import SearchResultsLayout from '../components/SearchResultsLayout';

describe('SearchResultsLayout', () => {
  it('shows a message when there is no search query', () => {
    render(<SearchResultsLayout params={{}} resultsData={null} vertical='web' />);
    const message = screen.getByText(/Please enter a search term in the box above./i);
    expect(message).toBeInTheDocument();
  });

  it('renders all relevant links', () => {
    render(<SearchResultsLayout params={{}} resultsData={{ results: [], totalPages: 1, unboundedResults: false }} vertical='web' />);
    const linkToMoreDropdown = screen.getAllByText(/More/i);
    const relatedSites = screen.getByText(/Related Sites/i);
    expect(linkToMoreDropdown[0]).toBeInTheDocument();
    expect(relatedSites).toBeInTheDocument();
  });

  it('renders search results', () => {
    const results : any[] = []; // eslint-disable-line @typescript-eslint/no-explicit-any
    for (let counter = 0; counter < 20; counter += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023' });
    }
    const resultsData = { totalPages: 2, unboundedResults: true, results };
    render(<SearchResultsLayout params={{ query: 'foo' }} resultsData={resultsData} vertical='web' />);
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
    render(<SearchResultsLayout params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' />);
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
    render(<SearchResultsLayout params={{ query: 'foo' }} resultsData={resultsData} additionalResults={additionalResults} vertical='web' />);
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
    render(<SearchResultsLayout params={{ query: 'foo' }} resultsData={resultsData} vertical='image' />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
    expect(img).toHaveAttribute('alt', 'test result 1');
  });
});



