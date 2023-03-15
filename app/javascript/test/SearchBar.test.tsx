import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { SearchBar } from '../components/SearchBar/SearchBar';

describe('SearchBar', () => {
  // it('Search Bar with Results', () => {
  //   const results = [{ title: 'test result 1', unescapedUrl: 'https://www.search.gov', thumbnail: { url: 'https://www.search.gov/test_image.png' }, content: 'result body' }];

  //   render(<SearchBar query='test result' results={results} />);

  //   const searchInput = screen.getByTestId('search-field');

  //   const searchBtn = screen.getByTestId('search-submit-btn');

  //   expect(searchInput).toHaveTextContent('test result');

  //   // fireEvent.change(searchInput, { target: { value: "test" } });
  //   // fireEvent.click(searchBtn);

  //   // const inputTextWithResults = screen.getByText(/test./i);
  //   // expect(inputTextWithResults).toBeInTheDocument();
  // });

  it('Search Bar with No Results', () => {
    render(<SearchBar query='medical' results={[]} />);

    const searchInput = screen.getByTestId('search-field');
    const searchBtn = screen.getByTestId('search-submit-btn');

    fireEvent.change(searchInput, { target: { value: "ssn" } });
    fireEvent.click(searchBtn);

    const inputTextWithResults = screen.getByText(/Please enter a search term in the box above./i);
    expect(inputTextWithResults).toBeInTheDocument();
  });
});
