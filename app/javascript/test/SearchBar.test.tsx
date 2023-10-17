import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { SearchBar } from '../components/SearchBar/SearchBar';
import { LanguageContext } from '../contexts/LanguageContext';

const locale = {
  en: {
    emptyQuery: 'Please enter a search term in the box above.'
  }
};

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const i18n = new I18n(locale);

describe('SearchBar', () => {
  it('Search Bar with No Query', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SearchBar query="" />
      </LanguageContext.Provider>
    );

    const searchInput = screen.getByTestId('search-field');
    const searchBtn = screen.getByTestId('search-submit-btn');

    fireEvent.change(searchInput, { target: { value: 'ssn' } });
    fireEvent.click(searchBtn);

    const inputTextWithResults = screen.getByText(/Please enter a search term in the box above./i);
    expect(inputTextWithResults).toBeInTheDocument();
  });
});
