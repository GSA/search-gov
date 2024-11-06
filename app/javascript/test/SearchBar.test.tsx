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

describe('SearchBar with no facets', () => {
  it('Search Bar with No Query', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SearchBar query="" navigationLinks={[]} />
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

describe('Tablet & Mobile view: SearchBar with facets', () => {
  // beforeAll(() => {
  //   window.innerWidth = 400;
  // });

  it('Filter search label and filter button is present', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SearchBar query="" navigationLinks={[]} facetsEnabled={true} mobileView={true} />
      </LanguageContext.Provider>
    );

    const filterLabel = screen.getByText(/Filter search/i);
    expect(filterLabel).toBeInTheDocument();
    
    const filterSearchBtn = screen.getByTestId('filter-search-btn');
    fireEvent.click(filterSearchBtn);
  });

  it('Filter type, action buttons are present', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SearchBar query="" navigationLinks={[]} facetsEnabled={true} mobileView={true} />
      </LanguageContext.Provider>
    );

    const filterSearchBtn = screen.getByTestId('filter-search-btn');
    fireEvent.click(filterSearchBtn);

    const clearBtnLabel = screen.getByText(/Clear/i);
    expect(clearBtnLabel).toBeInTheDocument();

    const seeResultsBtnLabel = screen.getByText(/See Results/i);
    expect(seeResultsBtnLabel).toBeInTheDocument();

    const filterPanelCloseBtn = screen.getByTestId('filter-panel-close-btn');
    fireEvent.click(filterPanelCloseBtn);
  });
});
