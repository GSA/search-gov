import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { SearchBar } from '../components/SearchBar/SearchBar';

describe('SearchBar', () => {
  it('Search Bar with No Results', () => {
    render(<SearchBar results={[]} />);

    const searchInput = screen.getByTestId('search-field');
    const searchBtn = screen.getByTestId('search-submit-btn');

    fireEvent.change(searchInput, { target: { value: 'ssn' } });
    fireEvent.click(searchBtn);

    const inputTextWithResults = screen.getByText(/Please enter a search term in the box above./i);
    expect(inputTextWithResults).toBeInTheDocument();
  });
});
