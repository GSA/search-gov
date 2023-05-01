import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import SearchResultsLayout from '../components/SearchResultsLayout';

describe('SearchResultsLayout', () => {
  it('shows a message when there are no results', () => {
    render(<SearchResultsLayout params={{}} resultsData={{ results: [], totalPages: 0, unboundedResults: false }} vertical='web' />);
    const message = screen.getByText(/Please enter a search term in the box above./i);
    expect(message).toBeInTheDocument();
  });

  it('renders all relevant links', () => {
    render(<SearchResultsLayout params={{}} resultsData={{ results: [], totalPages: 0, unboundedResults: false }} vertical='web' />);
    const everything = screen.getByText(/More/i);
    const news = screen.getByText(/Related Sites/i);
    expect(everything).toBeInTheDocument();
    expect(news).toBeInTheDocument();
  });

  it('renders search results', () => {
    let results = []
    for (let i = 0; i < 20; i += 1) {
      results.push({ title: 'test result 1', url: 'https://www.search.gov', thumbnail: { url: 'https://www.search.gov/test_image.png' }, description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023', thumbnailUrl: null })
    }
    const resultsData = { totalPages: 2, unboundedResults: true, results: results };
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
    const resultsData = { totalPages: 2, unboundedResults: true, results: [{ title: 'test result 1', url: 'https://www.search.gov', thumbnail: { url: 'https://www.search.gov/test_image.png' }, description: 'result body', publishedDate: 'May 9th, 2023', updatedDate: 'May 10th, 2023', thumbnailUrl: null }] };
    render(<SearchResultsLayout params={{ query: 'foo' }} resultsData={resultsData} vertical='image' />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = [...document.getElementsByClassName('result-image')].pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
  });
});



