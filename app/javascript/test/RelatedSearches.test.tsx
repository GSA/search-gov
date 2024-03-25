/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, screen, render } from '@testing-library/react';
import React from 'react';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();
import { RelatedSearches } from '../components/Results/RelatedSearches/RelatedSearches';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Related Searches component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const relatedSearchProps = [{
    label: 'jupiter',
    link: '/search?affiliate=rss&query=jupiter+planet'
  }];

  const relatedSearchesProps = {
    affiliate: 'test_affiliate',
    relatedSearches: relatedSearchProps,
    query: 'related',
    vertical: 'web'
  };

  it('renders Related Searches component', () => {
    render(
      <RelatedSearches {...relatedSearchesProps}/>
    );
  });

  it('shows Related Searches title and its link', () => {
    render(
      <RelatedSearches {...relatedSearchesProps}/>
    );
    const link = Array.from(document.getElementsByClassName('result-title-link')).pop() as HTMLParagraphElement;
    expect(link).toHaveAttribute('href', '/search?affiliate=rss&query=jupiter+planet');
  });

  it('calls fetch with correct federal reg document click data', () => {
    render(<RelatedSearches {...relatedSearchesProps}/>);

    const link = screen.getByText(/jupiter/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=rss&query=jupiter+planet',
      module_code: 'SREL',
      position: 1,
      query: 'related',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});

describe('Mobile view: Related searches component clicking the content div', () => {
  beforeAll(() => {
    window.innerWidth = 450;
  });

  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const relatedSearchProps = [{
    label: 'jupiter',
    link: '/search?affiliate=rss&query=jupiter+planet'
  }];

  const relatedSearchesProps = {
    affiliate: 'test_affiliate',
    relatedSearches: relatedSearchProps,
    query: 'related',
    vertical: 'web'
  };

  it('calls fetch with correct related searches click data', () => {
    render(<RelatedSearches {...relatedSearchesProps}/>);

    const [linkDiv] = Array.from(document.getElementsByClassName('result-title'));
    fireEvent.click(linkDiv);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=rss&query=jupiter+planet',
      module_code: 'SREL',
      position: 1,
      query: 'related',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
