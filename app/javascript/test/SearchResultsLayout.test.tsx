import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import SearchResultsLayout from '../components/SearchResultsLayout';

describe('SearchResultsLayout', () => {
  it('shows a message when there are no results', () => {
    render(<SearchResultsLayout params="foo" results={[]} vertical="web" />);
    const message = screen.getByText(/Please enter a search term in the box above./i);
    expect(message).toBeInTheDocument();
  });

  it('renders all relevant links', () => {
    render(<SearchResultsLayout params="foo" results={[]} vertical="web" />);
    const everything = screen.getByText(/Everything/i);
    const news = screen.getByText(/News/i);
    const images = screen.getByText(/Images/i);
    const videos = screen.getByText(/Videos/i);
    expect(everything).toBeInTheDocument();
    expect(news).toBeInTheDocument();
    expect(images).toBeInTheDocument();
    expect(videos).toBeInTheDocument();
  });

  it('renders search results', () => {
    const results = [{ 'title': 'test result 1', 'unescapedUrl': 'https://www.search.gov', 'content': 'result body' }];
    render(<SearchResultsLayout params="foo" results={results} vertical="web" />);
    const resultTitle = screen.getByText(/test result 1/i);
    const resultUrl = screen.getByText(/https\:\/\/www.search.gov/i);
    const resultBody = screen.getByText(/result body/i);
    expect(resultTitle).toBeInTheDocument();
    expect(resultUrl).toBeInTheDocument();
    expect(resultBody).toBeInTheDocument();
  });

  it('renders image search results', () => {
    const results = [{ 'title': 'test result 1', 'thumbnail': { 'url': 'https://www.search.gov/test_image.png' } }];
    render(<SearchResultsLayout params="foo" results={results} vertical="image" />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = [...document.getElementsByClassName("result-image")].pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
  });
});



