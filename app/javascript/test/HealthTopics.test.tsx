import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

import { HealthTopics } from '../components/Results/HealthTopics/HealthTopics';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('HealthTopics component', () => {
  const healthTopic = {
    description: 'A1C is a blood test for type 2 diabetes and prediabetes.',
    title: 'A1C',
    url: 'https://medlineplus.gov/a1c.html',
    relatedTopics: [{
      title: 'Legionnaires Disease',
      url: 'https://medlineplus.gov/legionnairesdisease.html'
    }],
    studiesAndTrials: [{
      title: 'Pneumonia',
      url: 'https://clinicaltrials.gov/search?cond=%22Pneumonia%22&aggFilters=status:not%20rec'
    }]
  };
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  it('renders federal register component', () => {
    render(
      <HealthTopics {...healthTopic} affiliate='Test Affiliate' query='query' vertical='web' />
    );
  });

  it('shows related topics title, url and description', () => {
    render(
      <HealthTopics {...healthTopic} affiliate='Test Affiliate' query='query' vertical='web' />
    );
    expect(screen.getByText('A1C')).toBeInTheDocument();
    expect(screen.getByText('A1C is a blood test for type 2 diabetes and prediabetes.')).toBeInTheDocument();
  });

  it('shows related topics title and description', () => {
    render(
      <HealthTopics {...healthTopic} affiliate='Test Affiliate' query='query' vertical='web' />
    );
    expect(screen.getByText('Legionnaires Disease')).toBeInTheDocument();
    expect(screen.getByText('Pneumonia')).toBeInTheDocument();
  });

  it('calls fetch with correct click data on the health topic link', () => {
    render(<HealthTopics {...healthTopic} affiliate='Test Affiliate' query='query' vertical='web' />);

    const topicClickBody = {
      affiliate: 'Test Affiliate',
      url: 'https://medlineplus.gov/a1c.html',
      module_code: 'MEDL',
      position: 1,
      query: 'query',
      vertical: 'web'
    };

    const topicLink = screen.getByText('A1C');
    fireEvent.click(topicLink);

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(topicClickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('calls fetch with correct click data on the related links', () => {
    render(<HealthTopics {...healthTopic} affiliate='Test Affiliate' query='query' vertical='web' />);

    const relatedClickBody = {
      affiliate: 'Test Affiliate',
      url: 'https://medlineplus.gov/legionnairesdisease.html',
      module_code: 'MEDL',
      position: 2,
      query: 'query',
      vertical: 'web'
    };

    const relatedLink = screen.getByText('Legionnaires Disease');
    fireEvent.click(relatedLink);

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(relatedClickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('calls fetch with correct click data on studies and trials links', () => {
    render(<HealthTopics {...healthTopic} affiliate='Test Affiliate' query='query' vertical='web' />);

    const studiesClickBody = {
      affiliate: 'Test Affiliate',
      url: 'https://clinicaltrials.gov/search?cond=%22Pneumonia%22&aggFilters=status:not%20rec',
      module_code: 'MEDL',
      position: 3,
      query: 'query',
      vertical: 'web'
    };

    const studiesLink = screen.getByText('Pneumonia');
    fireEvent.click(studiesLink);

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(studiesClickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
