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
    const resultUrl = screen.getAllByText(/https:\/\/www.search.gov/i);
    const resultBody = screen.getAllByText(/result body/i);
    const publishedDate = screen.getAllByText(/May 9th, 2023/i);
    const updatedDate = screen.getAllByText(/Updated on May 10th, 2023/i);
    expect(resultTitle).toHaveLength(20);
    expect(resultUrl).toHaveLength(20);
    expect(resultBody).toHaveLength(20);
    expect(publishedDate).toHaveLength(20);
    expect(updatedDate).toHaveLength(20);
  });

  it('renders image search results', () => {
    const resultsData = { totalPages: 2, unboundedResults: true, results: [{ title: 'test result 1', url: 'https://www.search.gov', description: 'result body', thumbnail: { url: 'https://www.search.gov/test_image.png' }, publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023', thumbnailUrl: null }] };
    render(<SearchResultsLayout params={{ query: 'foo' }} resultsData={resultsData} vertical='image' />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
  });
});



