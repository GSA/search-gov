import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

import { Facets, AggregationData } from '../components/Facets/Facets';
import { LanguageContext } from '../contexts/LanguageContext';

const locale = {
  en: {
    facets: {
      "changed": 'Last Updated',
      "contentType": 'Content Type',
      "mimeType": "MIME Type",
      "searchgov_custom1": "Search Gov Custom 1",
      "searchgov_custom2": "Search Gov Custom 2",
      "searchgov_custom3": "Search Gov Custom 3",
      "tags": "Tags"
    },
  }
};

const i18n = new I18n(locale);

const dummnyAggregations: AggregationData[] =[
  {
    'contentType': [
      {
        aggKey: 'Press release',
        docCount: 2876
      },
      {
        aggKey: 'Blogs',
        docCount: 1923
      },
    ]
  },
  {
    'mimeType': [
      {
        aggKey: 'CSV',
        docCount: 2877
      },
      {
        aggKey: 'HTML',
        docCount: 1924
      },
    ]
  }
];

describe('Facets component', () => {
  it('renders Facets component', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Facets aggregations={dummnyAggregations} />
      </LanguageContext.Provider>
    );
  });

  it('shows Filter search label', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Facets aggregations={dummnyAggregations} />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('Filter search')).toBeInTheDocument();
  });

  it('shows aggegations', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Facets aggregations={dummnyAggregations} />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('Content Type')).toBeInTheDocument();
    expect(screen.getByText('Press release')).toBeInTheDocument();

    expect(screen.getByText('MIME Type')).toBeInTheDocument();
    expect(screen.getByText('CSV')).toBeInTheDocument();

    expect(screen.getByText('Date Range')).toBeInTheDocument();
    expect(screen.getByText('Last year')).toBeInTheDocument();

    const checkbox1 = screen.getByRole('checkbox', { name: /Press release/i });
    expect(checkbox1).not.toBeChecked();

    fireEvent.click(checkbox1);
    expect(checkbox1).toBeChecked();

    fireEvent.click(checkbox1);
    expect(checkbox1).not.toBeChecked();

    const checkbox2 = screen.getByRole('checkbox', { name: /CSV/i });
    const checkbox3 = screen.getByRole('checkbox', { name: /HTML/i });

    // Initially, selectedIds should be empty
    expect(checkbox2).not.toBeChecked();
    expect(checkbox3).not.toBeChecked();

    fireEvent.click(checkbox2);
    expect(checkbox2).toBeChecked();

    fireEvent.click(checkbox3);
    expect(checkbox3).toBeChecked();

    fireEvent.click(checkbox2);
    expect(checkbox2).not.toBeChecked();
  });

  it('shows Clear and See Results button', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Facets aggregations={dummnyAggregations} />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('Clear')).toBeInTheDocument();
    expect(screen.getByText('See Results')).toBeInTheDocument();

    const seeResultsBtnLabel = screen.getByText(/See Results/i);
    fireEvent.click(seeResultsBtnLabel);

    const clearBtnLabel = screen.getByText(/Clear/i);
    fireEvent.click(clearBtnLabel);
  });
});
